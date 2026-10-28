import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import {
  doc, getDoc, setDoc, updateDoc, writeBatch, serverTimestamp, increment, arrayUnion, arrayRemove, deleteField,
} from 'firebase/firestore';

const G = 'grp0000000000000000001';
const CODE = 'invite0000000001';
const SECRET = 'secret-secret-secret';
let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-arnav-chat',
    firestore: { rules: readFileSync(resolve(import.meta.dirname, '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => env?.cleanup());
beforeEach(async () => env.clearFirestore());

const db = (uid) => env.authenticatedContext(uid).firestore();

/** Exactly what GroupRepository.create() writes. */
function createGroup(uid, members = [uid, 'bob'], extra = {}) {
  const f = db(uid);
  const b = writeBatch(f);
  b.set(doc(f, 'chats', G), {
    type: 'group', members, admins: [uid], name: 'Crew', photoUrl: null, description: null,
    createdBy: uid, inviteCode: null, topicSecret: SECRET, seq: 1, readSeq: { [uid]: 1 },
    updatedAt: serverTimestamp(),
    lastMessage: { id: 'sys1', senderId: uid, kind: 'system', preview: 'created the group', at: serverTimestamp() },
    ...extra,
  });
  b.set(doc(f, 'chats', G, 'messages', 'sys1'), {
    senderId: uid, createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
    payload: { v: 1, enc: 'none', kind: 'system', text: 'created the group' },
  });
  return b.commit();
}

function groupSend(uid, id, payload = { v: 1, enc: 'none', kind: 'text', text: 'hi' }) {
  const f = db(uid);
  const b = writeBatch(f);
  b.set(doc(f, 'chats', G, 'messages', id), { senderId: uid, createdAt: serverTimestamp(), updatedAt: serverTimestamp(), payload });
  b.update(doc(f, 'chats', G), {
    updatedAt: serverTimestamp(), seq: increment(1), [`readSeq.${uid}`]: increment(1),
    lastMessage: { id, senderId: uid, kind: payload.kind, preview: 'hi', at: serverTimestamp() },
  });
  return b.commit();
}

async function withInvite() {
  await createGroup('alice');
  const f = db('alice');
  const b = writeBatch(f);
  b.update(doc(f, 'chats', G), { inviteCode: CODE, updatedAt: serverTimestamp() });
  b.set(doc(f, 'invites', CODE), { chatId: G, name: 'Crew', photoUrl: null, memberCount: 2, updatedAt: serverTimestamp() });
  await b.commit();
}

describe('groups', () => {
  it('a user creates a group they administer', async () => {
    await assertSucceeds(createGroup('alice'));
  });

  it('cannot create a group naming someone else as creator/admin only', async () => {
    const f = db('eve');
    await assertFails(setDoc(doc(f, 'chats', G), {
      type: 'group', members: ['eve', 'bob'], admins: ['bob'], name: 'x', createdBy: 'eve',
      topicSecret: SECRET, seq: 0, updatedAt: serverTimestamp(),
    }));
  });

  it('members send; seq must advance by exactly one', async () => {
    await createGroup('alice');
    await assertSucceeds(groupSend('bob', 'm1'));
    const f = db('bob');
    await assertFails(updateDoc(doc(f, 'chats', G), {
      seq: 99, updatedAt: serverTimestamp(),
      lastMessage: { id: 'x', senderId: 'bob', kind: 'text', preview: 'x', at: serverTimestamp() },
    }));
  });

  it('non-members can neither read nor send', async () => {
    await createGroup('alice');
    await assertFails(getDoc(doc(db('eve'), 'chats', G)));
    await assertFails(groupSend('eve', 'm1'));
  });

  it('members mark read only for themselves and never past seq', async () => {
    await createGroup('alice');
    await assertSucceeds(updateDoc(doc(db('bob'), 'chats', G), { 'readSeq.bob': 1, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db('bob'), 'chats', G), { 'readSeq.alice': 0, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db('bob'), 'chats', G), { 'readSeq.bob': 50, updatedAt: serverTimestamp() }));
  });

  it('only admins rename, add members or change admins', async () => {
    await createGroup('alice');
    await assertSucceeds(updateDoc(doc(db('alice'), 'chats', G), { name: 'New', members: arrayUnion('carol'), updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db('bob'), 'chats', G), { name: 'Mine', updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db('bob'), 'chats', G), { admins: arrayUnion('bob'), updatedAt: serverTimestamp() }));
  });

  it('a member can leave but cannot remove others', async () => {
    await createGroup('alice', ['alice', 'bob', 'carol']);
    await assertFails(updateDoc(doc(db('bob'), 'chats', G), { members: arrayRemove('carol'), updatedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(doc(db('bob'), 'chats', G), { members: arrayRemove('bob'), updatedAt: serverTimestamp() }));
    await assertFails(getDoc(doc(db('bob'), 'chats', G, 'messages', 'sys1')));
  });

  it('pins are admin-only in groups', async () => {
    await createGroup('alice');
    await assertFails(updateDoc(doc(db('bob'), 'chats', G), { pinned: [{ id: 'sys1' }], updatedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(doc(db('alice'), 'chats', G), { pinned: [{ id: 'sys1' }], updatedAt: serverTimestamp() }));
  });
});

describe('invites', () => {
  it('only an admin publishes the invite card for the current code', async () => {
    await withInvite();
    await assertSucceeds(getDoc(doc(db('eve'), 'invites', CODE)));
    // A member who is not an admin cannot overwrite it, nor mint a card for another code.
    await assertFails(setDoc(doc(db('bob'), 'invites', CODE), { chatId: G, name: 'Hijacked', updatedAt: serverTimestamp() }));
    await assertFails(setDoc(doc(db('alice'), 'invites', 'othercode00001'), { chatId: G, name: 'Crew', updatedAt: serverTimestamp() }));
  });

  it('anyone with the code can join; a wrong code is rejected', async () => {
    await withInvite();
    await assertFails(updateDoc(doc(db('eve'), 'chats', G), {
      members: arrayUnion('eve'), lastJoinCode: 'wrongwrongwrong', updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(doc(db('eve'), 'chats', G), {
      members: arrayUnion('eve'), lastJoinCode: CODE, updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(getDoc(doc(db('eve'), 'chats', G)));
  });

  it('joining cannot smuggle in other users or admin rights', async () => {
    await withInvite();
    await assertFails(updateDoc(doc(db('eve'), 'chats', G), {
      members: arrayUnion('eve', 'mallory'), lastJoinCode: CODE, updatedAt: serverTimestamp(),
    }));
    await assertFails(updateDoc(doc(db('eve'), 'chats', G), {
      members: arrayUnion('eve'), admins: arrayUnion('eve'), lastJoinCode: CODE, updatedAt: serverTimestamp(),
    }));
  });
});

describe('polls & pins in direct chats', () => {
  async function directPoll() {
    const f = db('alice');
    const b = writeBatch(f);
    b.set(doc(f, 'chats', 'alice_bob', 'messages', 'p1'), {
      senderId: 'alice', createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
      payload: { v: 1, enc: 'none', kind: 'poll', text: 'Lunch?', poll: { q: 'Lunch?', opts: [{ id: 'a', t: 'Yes' }, { id: 'b', t: 'No' }] } },
    });
    b.set(doc(f, 'chats', 'alice_bob'), {
      type: 'direct', members: ['alice', 'bob'], updatedAt: serverTimestamp(),
      lastMessage: { id: 'p1', senderId: 'alice', kind: 'poll', preview: 'Poll', at: serverTimestamp() },
      unread: { bob: increment(1) },
    }, { merge: true });
    await b.commit();
  }

  it('members vote with their own key only', async () => {
    await directPoll();
    const ref = doc(db('bob'), 'chats', 'alice_bob', 'messages', 'p1');
    await assertSucceeds(updateDoc(ref, { 'votes.bob': ['a'], updatedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(ref, { 'votes.bob': deleteField(), updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { 'votes.alice': ['b'], updatedAt: serverTimestamp() }));
  });

  it('either member pins in a direct chat (max 5)', async () => {
    await directPoll();
    const ref = doc(db('bob'), 'chats', 'alice_bob');
    await assertSucceeds(updateDoc(ref, { pinned: [{ id: 'p1', senderId: 'alice', preview: 'Poll' }], updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { pinned: [1, 2, 3, 4, 5, 6], updatedAt: serverTimestamp() }));
  });

  it('chat state and folders are private to their owner', async () => {
    await assertSucceeds(setDoc(doc(db('alice'), 'users', 'alice', 'chatState', 'alice_bob'), { pinned: true, updatedAt: serverTimestamp() }));
    await assertFails(getDoc(doc(db('bob'), 'users', 'alice', 'chatState', 'alice_bob')));
    await assertSucceeds(setDoc(doc(db('alice'), 'users', 'alice', 'folders', 'f1'), { name: 'Work', flags: 2, chatIds: [], order: 0 }));
    await assertFails(setDoc(doc(db('alice'), 'users', 'alice', 'folders', 'f2'), { name: 'x'.repeat(40), flags: 0, chatIds: [], order: 0 }));
  });
});
