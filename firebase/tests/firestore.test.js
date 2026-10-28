import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc, writeBatch, serverTimestamp, increment,
  collection, query, where, getDocs, deleteField,
} from 'firebase/firestore';

const PROJECT = 'demo-arnav-chat';
const ALICE = 'alice';
const BOB = 'bob';
const EVE = 'eve';
const CHAT = 'alice_bob';

let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: { rules: readFileSync(resolve(import.meta.dirname, '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => env?.cleanup());
beforeEach(async () => env.clearFirestore());

const db = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

const profile = (uid, name) => ({
  uid, username: name, usernameLower: name, displayName: name.toUpperCase(),
  photoUrl: null, bio: null, privacy: { lastSeen: 'everyone', readReceipts: true }, createdAt: serverTimestamp(),
});

async function claim(uid, name) {
  const f = db(uid);
  const b = writeBatch(f);
  b.set(doc(f, 'usernames', name), { uid, createdAt: serverTimestamp() });
  b.set(doc(f, 'users', uid), profile(uid, name));
  return b.commit();
}

/** The exact batch MessageWriter.send() performs. */
function sendBatch(uid, chatId, id, members, text = 'hi') {
  const f = db(uid);
  const peer = members.find((m) => m !== uid);
  const b = writeBatch(f);
  b.set(doc(f, 'chats', chatId, 'messages', id), {
    senderId: uid, createdAt: serverTimestamp(), updatedAt: serverTimestamp(), clientTs: Date.now(),
    payload: { v: 1, enc: 'none', kind: 'text', text },
  });
  b.set(doc(f, 'chats', chatId), {
    type: members.length === 1 ? 'self' : 'direct', members, updatedAt: serverTimestamp(),
    lastMessage: { id, senderId: uid, kind: 'text', preview: text, at: serverTimestamp() },
    unread: peer ? { [peer]: increment(1) } : {},
  }, { merge: true });
  return b.commit();
}

async function seedChat() {
  await sendBatch(ALICE, CHAT, 'm1', [ALICE, BOB]);
}

describe('users & usernames', () => {
  it('lets a user claim a free username and create their profile', async () => {
    await assertSucceeds(claim(ALICE, 'alice'));
  });

  it('rejects claiming a username someone else owns', async () => {
    await claim(ALICE, 'alice');
    await assertFails(claim(EVE, 'alice'));
  });

  it('rejects invalid usernames', async () => {
    await assertFails(claim(ALICE, 'Al!ce'));
    await assertFails(claim(ALICE, 'ab'));
  });

  it('only the owner can edit a profile', async () => {
    await claim(ALICE, 'alice');
    await assertSucceeds(updateDoc(doc(db(ALICE), 'users', ALICE), { bio: 'hello' }));
    await assertFails(updateDoc(doc(db(EVE), 'users', ALICE), { bio: 'hacked' }));
  });

  it('username cannot be changed after onboarding', async () => {
    await claim(ALICE, 'alice');
    await assertFails(updateDoc(doc(db(ALICE), 'users', ALICE), { username: 'zed', usernameLower: 'zed' }));
  });

  it('signed-in users can read profiles; anonymous cannot', async () => {
    await claim(ALICE, 'alice');
    await assertSucceeds(getDoc(doc(db(BOB), 'users', ALICE)));
    await assertFails(getDoc(doc(anon(), 'users', ALICE)));
  });

  it('private data (FCM tokens) is owner-only', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE, 'private', 'meta'), { fcmTokens: ['t'] }));
    await assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'private', 'meta')));
  });

  it('contacts are owner-only', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE, 'contacts', BOB), { addedAt: serverTimestamp() }));
    await assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'contacts', BOB)));
  });
});

describe('chats', () => {
  it('a member can start a direct chat with the first message batch', async () => {
    await assertSucceeds(sendBatch(ALICE, CHAT, 'm1', [ALICE, BOB]));
  });

  it('cannot create a chat with a forged id or without being a member', async () => {
    await assertFails(sendBatch(EVE, CHAT, 'm1', [ALICE, BOB]));
    await assertFails(sendBatch(ALICE, 'bob_alice', 'm1', [BOB, ALICE]));
  });

  it('saved messages: a chat with yourself', async () => {
    await assertSucceeds(sendBatch(ALICE, ALICE, 'm1', [ALICE]));
    await assertFails(sendBatch(EVE, ALICE, 'm2', [ALICE]));
  });

  it('only members can read the chat and its messages', async () => {
    await seedChat();
    await assertSucceeds(getDoc(doc(db(BOB), 'chats', CHAT)));
    await assertSucceeds(getDoc(doc(db(BOB), 'chats', CHAT, 'messages', 'm1')));
    await assertFails(getDoc(doc(db(EVE), 'chats', CHAT)));
    await assertFails(getDoc(doc(db(EVE), 'chats', CHAT, 'messages', 'm1')));
  });

  it('chat list query is allowed only for my own membership', async () => {
    await seedChat();
    await assertSucceeds(getDocs(query(collection(db(BOB), 'chats'), where('members', 'array-contains', BOB))));
    await assertFails(getDocs(query(collection(db(EVE), 'chats'), where('members', 'array-contains', BOB))));
  });

  it('reading a not-yet-created chat is allowed (no data leaked)', async () => {
    await assertSucceeds(getDoc(doc(db(EVE), 'chats', 'eve_zed')));
  });

  it('the peer can reply in the same chat', async () => {
    await seedChat();
    await assertSucceeds(sendBatch(BOB, CHAT, 'm2', [ALICE, BOB]));
  });

  it('members can mark read (own counters only)', async () => {
    await seedChat();
    await assertSucceeds(updateDoc(doc(db(BOB), 'chats', CHAT), {
      'unread.bob': 0, 'readUpTo.bob': serverTimestamp(), 'deliveredUpTo.bob': serverTimestamp(), updatedAt: serverTimestamp(),
    }));
    await assertFails(updateDoc(doc(db(BOB), 'chats', CHAT), { 'readUpTo.alice': serverTimestamp(), updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db(BOB), 'chats', CHAT), { 'unread.alice': 50, updatedAt: serverTimestamp() }));
  });

  it('members list and type are immutable; non-members cannot update', async () => {
    await seedChat();
    await assertFails(updateDoc(doc(db(ALICE), 'chats', CHAT), { members: [ALICE, BOB, EVE], updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db(EVE), 'chats', CHAT), { 'unread.eve': 0, updatedAt: serverTimestamp() }));
  });

  it('lastMessage can only be authored by me', async () => {
    await seedChat();
    await assertFails(updateDoc(doc(db(BOB), 'chats', CHAT), {
      lastMessage: { id: 'x', senderId: ALICE, kind: 'text', preview: 'forged', at: serverTimestamp() }, updatedAt: serverTimestamp(),
    }));
  });

  it('chats cannot be deleted', async () => {
    await seedChat();
    await assertFails(deleteDoc(doc(db(ALICE), 'chats', CHAT)));
  });
});

describe('messages', () => {
  it('cannot send as someone else', async () => {
    await seedChat();
    const f = db(BOB);
    await assertFails(setDoc(doc(f, 'chats', CHAT, 'messages', 'x'), {
      senderId: ALICE, createdAt: serverTimestamp(), updatedAt: serverTimestamp(), payload: { v: 1, enc: 'none', kind: 'text', text: 'x' },
    }));
  });

  it('timestamps must be server time', async () => {
    await seedChat();
    await assertFails(setDoc(doc(db(ALICE), 'chats', CHAT, 'messages', 'x'), {
      senderId: ALICE, createdAt: new Date(0), updatedAt: new Date(0), payload: { v: 1, enc: 'none', kind: 'text', text: 'x' },
    }));
  });

  it('sender can edit; peer cannot', async () => {
    await seedChat();
    const edit = { payload: { v: 1, enc: 'none', kind: 'text', text: 'edited' }, editedAt: serverTimestamp(), updatedAt: serverTimestamp() };
    await assertSucceeds(updateDoc(doc(db(ALICE), 'chats', CHAT, 'messages', 'm1'), edit));
    await assertFails(updateDoc(doc(db(BOB), 'chats', CHAT, 'messages', 'm1'), edit));
  });

  it('sender can delete for everyone (tombstone); nobody can hard-delete', async () => {
    await seedChat();
    await assertSucceeds(updateDoc(doc(db(ALICE), 'chats', CHAT, 'messages', 'm1'), {
      payload: { v: 1, enc: 'none', kind: 'deleted' }, deleted: true, updatedAt: serverTimestamp(),
    }));
    await assertFails(deleteDoc(doc(db(ALICE), 'chats', CHAT, 'messages', 'm1')));
  });

  it('members react with their own key only', async () => {
    await seedChat();
    const ref = doc(db(BOB), 'chats', CHAT, 'messages', 'm1');
    await assertSucceeds(updateDoc(ref, { 'reactions.bob': '❤️', updatedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(ref, { 'reactions.bob': deleteField(), updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { 'reactions.alice': '👍', updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db(EVE), 'chats', CHAT, 'messages', 'm1'), { 'reactions.eve': '👍', updatedAt: serverTimestamp() }));
  });

  it('rejects oversized text', async () => {
    await assertFails(sendBatch(ALICE, CHAT, 'big', [ALICE, BOB], 'x'.repeat(5000)));
  });
});
