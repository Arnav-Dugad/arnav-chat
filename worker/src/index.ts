import { verifyFirebaseToken } from './auth';
import { cloudinarySignature, UPLOAD_KINDS, type UploadKind } from './cloudinary';
import { type Env, HttpError } from './env';
import { Firestore } from './firestore';
import { googleAccessToken } from './google';

const CORS = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'POST, GET, OPTIONS',
  'access-control-allow-headers': 'authorization, content-type',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json', ...CORS } });

// Small per-isolate caches keep Firestore reads (free quota) low.
const cache = new Map<string, { v: unknown; exp: number }>();
async function cached<T>(key: string, ttlMs: number, load: () => Promise<T>): Promise<T> {
  const hit = cache.get(key);
  if (hit && hit.exp > Date.now()) return hit.v as T;
  const v = await load();
  cache.set(key, { v, exp: Date.now() + ttlMs });
  if (cache.size > 2000) cache.delete(cache.keys().next().value!);
  return v;
}

async function limit(limiter: Env['NOTIFY_LIMITER'] | undefined, uid: string) {
  if (!limiter) return;
  const { success } = await limiter.limit({ key: uid });
  if (!success) throw new HttpError(429, 'rate limited');
}

async function body<T>(request: Request): Promise<T> {
  try {
    return (await request.json()) as T;
  } catch {
    throw new HttpError(400, 'invalid json');
  }
}

async function uploadSignature(request: Request, env: Env, uid: string) {
  await limit(env.UPLOAD_LIMITER, uid);
  const { kind } = await body<{ kind?: string }>(request);
  if (!kind || !UPLOAD_KINDS.includes(kind as UploadKind)) throw new HttpError(400, 'bad kind');
  const timestamp = Math.floor(Date.now() / 1000);
  const folder = `arnav-chat/${uid}/${kind}`;
  const signature = await cloudinarySignature({ folder, timestamp }, env.CLOUDINARY_API_SECRET);
  return json({ cloudName: env.CLOUDINARY_CLOUD_NAME, apiKey: env.CLOUDINARY_API_KEY, timestamp, signature, folder });
}

async function notify(request: Request, env: Env, uid: string) {
  await limit(env.NOTIFY_LIMITER, uid);
  const b = await body<{ chatId?: string; messageId?: string; preview?: string; kind?: string }>(request);
  if (!b.chatId || !b.messageId || !/^[\w-]{1,200}$/.test(b.chatId) || !/^[\w-]{1,64}$/.test(b.messageId)) {
    throw new HttpError(400, 'bad request');
  }
  const token = () => googleAccessToken(env.FIREBASE_SERVICE_ACCOUNT);
  const fs = new Firestore(env.FIREBASE_PROJECT_ID, token);

  // The sender must be a member of the chat — otherwise nothing is sent.
  const chat = await cached(`chat:${b.chatId}`, 60_000, () => fs.get(`chats/${b.chatId}`));
  const members = (chat?.members as string[] | undefined) ?? [];
  if (!members.includes(uid)) throw new HttpError(403, 'not a member');

  const sender = await cached(`user:${uid}`, 600_000, () => fs.get(`users/${uid}`));
  const senderName = String(sender?.displayName ?? 'New message').slice(0, 60);
  const preview = String(b.preview ?? '').slice(0, 160);
  const recipients = members.filter((m) => m !== uid);

  const accessToken = await token();
  let sent = 0;
  for (const r of recipients) {
    const meta = await cached(`tokens:${r}`, 300_000, () => fs.get(`users/${r}/private/meta`));
    const tokens = ((meta?.fcmTokens as string[] | undefined) ?? []).slice(-5);
    const dead: string[] = [];
    await Promise.all(tokens.map(async (t) => {
      const res = await fetch(`https://fcm.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/messages:send`, {
        method: 'POST',
        headers: { authorization: `Bearer ${accessToken}`, 'content-type': 'application/json' },
        body: JSON.stringify({
          message: {
            token: t,
            // Data-only: the app renders a grouped MessagingStyle notification
            // with inline reply, even when killed.
            data: { type: 'message', chatId: b.chatId!, messageId: b.messageId!, senderId: uid, senderName, preview, kind: String(b.kind ?? 'text') },
            android: { priority: 'HIGH', ttl: '86400s' },
          },
        }),
      });
      if (res.ok) sent++;
      else if (res.status === 404 || res.status === 400) dead.push(t);
    }));
    if (dead.length) {
      cache.delete(`tokens:${r}`);
      await fs.arrayRemove(`users/${r}/private/meta`, 'fcmTokens', dead).catch(() => {});
    }
  }
  return json({ sent });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (request.method === 'OPTIONS') return new Response(null, { headers: CORS });
    try {
      if (request.method === 'GET' && url.pathname === '/health') return json({ ok: true });
      if (request.method !== 'POST') throw new HttpError(405, 'method not allowed');
      const uid = await verifyFirebaseToken(request, env.FIREBASE_PROJECT_ID);
      switch (url.pathname) {
        case '/v1/upload-signature':
          return await uploadSignature(request, env, uid);
        case '/v1/notify':
          return await notify(request, env, uid);
        default:
          throw new HttpError(404, 'not found');
      }
    } catch (e) {
      if (e instanceof HttpError) return json({ error: e.message }, e.status);
      console.error(e);
      return json({ error: 'internal' }, 500);
    }
  },
} satisfies ExportedHandler<Env>;
