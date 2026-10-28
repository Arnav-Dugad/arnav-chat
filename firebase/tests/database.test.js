import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { ref, set, get, serverTimestamp } from 'firebase/database';

let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-arnav-chat',
    database: { rules: readFileSync(resolve(import.meta.dirname, '../database.rules.json'), 'utf8') },
  });
});
afterAll(async () => env?.cleanup());
beforeEach(async () => env.clearDatabase());

const rtdb = (uid) => env.authenticatedContext(uid).database();

describe('presence', () => {
  it('users write only their own status', async () => {
    await assertSucceeds(set(ref(rtdb('alice'), 'status/alice'), { online: true, lastSeen: serverTimestamp() }));
    await assertFails(set(ref(rtdb('eve'), 'status/alice'), { online: false }));
  });

  it('rejects malformed status', async () => {
    await assertFails(set(ref(rtdb('alice'), 'status/alice'), { online: 'yes' }));
    await assertFails(set(ref(rtdb('alice'), 'status/alice'), { online: true, extra: 1 }));
  });

  it('signed-in users can read status', async () => {
    await assertSucceeds(get(ref(rtdb('bob'), 'status/alice')));
    await assertFails(get(ref(env.unauthenticatedContext().database(), 'status/alice')));
  });
});

describe('typing', () => {
  it('only chat members write their own typing flag', async () => {
    await assertSucceeds(set(ref(rtdb('alice'), 'typing/alice_bob/alice'), serverTimestamp()));
    await assertFails(set(ref(rtdb('alice'), 'typing/alice_bob/bob'), serverTimestamp()));
    await assertFails(set(ref(rtdb('eve'), 'typing/alice_bob/eve'), serverTimestamp()));
  });

  it('only chat members read typing', async () => {
    await assertSucceeds(get(ref(rtdb('bob'), 'typing/alice_bob')));
    await assertFails(get(ref(rtdb('eve'), 'typing/alice_bob')));
  });
});
