import { describe, expect, it } from 'vitest';
import { cloudinarySignature } from '../src/cloudinary';
import { decodeFields } from '../src/firestore';
import worker from '../src/index';

describe('cloudinarySignature', () => {
  it('matches Cloudinary documented example', async () => {
    // https://cloudinary.com/documentation/authentication_signatures
    const sig = await cloudinarySignature(
      { eager: 'w_400,h_300,c_pad|w_260,h_200,c_crop', public_id: 'sample_image', timestamp: 1315060510 },
      'abcd',
    );
    expect(sig).toBe('bfd09f95f331f558cbd1320e67aa8d488770583e');
  });
});

describe('decodeFields', () => {
  it('decodes nested Firestore REST values', () => {
    const out = decodeFields({
      members: { arrayValue: { values: [{ stringValue: 'a' }, { stringValue: 'b' }] } },
      unread: { mapValue: { fields: { b: { integerValue: '3' } } } },
      ok: { booleanValue: true },
      none: { nullValue: null },
    });
    expect(out).toEqual({ members: ['a', 'b'], unread: { b: 3 }, ok: true, none: null });
  });
});

describe('routing & auth', () => {
  const env = {} as never;
  it('health is public', async () => {
    const res = await worker.fetch(new Request('https://w/health'), env);
    expect(res.status).toBe(200);
  });
  it('rejects requests without a Firebase token', async () => {
    const res = await worker.fetch(new Request('https://w/v1/notify', { method: 'POST', body: '{}' }), { FIREBASE_PROJECT_ID: 'p' } as never);
    expect(res.status).toBe(401);
  });
  it('rejects a forged token', async () => {
    const res = await worker.fetch(
      new Request('https://w/v1/upload-signature', { method: 'POST', headers: { Authorization: 'Bearer abc.def.ghi' }, body: '{}' }),
      { FIREBASE_PROJECT_ID: 'p' } as never,
    );
    expect(res.status).toBe(401);
  });
});

describe('invite landing page', () => {
  it('serves a deep-link page for a valid code', async () => {
    const res = await worker.fetch(new Request('https://w/j/AbCdEfGh2345678'), {} as never);
    expect(res.status).toBe(200);
    expect(await res.text()).toContain('arnavchat://app/join/AbCdEfGh2345678');
  });
  it('rejects malformed codes', async () => {
    const res = await worker.fetch(new Request('https://w/j/<script>'), {} as never);
    expect(res.status).not.toBe(200);
  });
});
