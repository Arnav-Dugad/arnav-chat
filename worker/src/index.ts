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

/** Invite landing page: opens the app, or offers the APK. */
function invitePage(code: string): Response {
  const deep = `arnavchat://app/join/${code}`;
  const apk = 'https://github.com/Arnav-Dugad/arnav-chat/releases/latest/download/arnav-chat-universal.apk';
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Join on Arnav Chat</title><meta name="robots" content="noindex">
<style>:root{color-scheme:dark}body{margin:0;min-height:100vh;display:grid;place-items:center;background:#0A0B10;color:#F3F5F9;font:16px/1.4 system-ui,sans-serif}
main{width:min(360px,90vw);text-align:center}.logo{width:88px;height:88px;border-radius:24px;margin:0 auto 20px;background:linear-gradient(135deg,#0D1A4A,#2350E6 55%,#27C1D9)}
a{display:block;padding:16px;border-radius:999px;text-decoration:none;font-weight:600;margin-top:12px}.p{background:linear-gradient(135deg,#2F5BEA,#27B4D9);color:#fff}.s{background:#1B1E27;color:#F3F5F9}</style></head>
<body><main><div class="logo"></div><h1 style="font-size:24px;margin:0 0 6px">You're invited</h1><p style="color:#9BA4B4;margin:0 0 20px">Open in Arnav Chat to join the group.</p>
<a class="p" href="${deep}">Open Arnav Chat</a><a class="s" href="${apk}">Download the app</a></main>
<script>location.href=${JSON.stringify(deep)}</script></body></html>`;
  return new Response(html, { headers: { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'public, max-age=300' } });
}

async function notify(request: Request, env: Env, uid: string) {
  await limit(env.NOTIFY_LIMITER, uid);
  const b = await body<{ chatId?: string; messageId?: string; preview?: string; kind?: string; mentions?: string[] }>(request);
  if (!b.chatId || !b.messageId || !/^[\w-]{1,200}$/.test(b.chatId) || !/^[\w-]{1,64}$/.test(b.messageId)) {
    throw new HttpError(400, 'bad request');
  }
  const token = () => googleAccessToken(env.FIREBASE_SERVICE_ACCOUNT);
  const fs = new Firestore(env.FIREBASE_PROJECT_ID, token);

  // The sender must be a member of the chat — otherwise nothing is sent.
  let chat = await cached(`chat:${b.chatId}`, 60_000, () => fs.get(`chats/${b.chatId}`));
  let members = (chat?.members as string[] | undefined) ?? [];
  if (!members.includes(uid)) {
    // Membership may have changed since the cached read (e.g. just added).
    chat = await fs.get(`chats/${b.chatId}`);
    cache.set(`chat:${b.chatId}`, { v: chat, exp: Date.now() + 60_000 });
    members = (chat?.members as string[] | undefined) ?? [];
  }
  if (!members.includes(uid)) throw new HttpError(403, 'not a member');

  const sender = await cached(`user:${uid}`, 600_000, () => fs.get(`users/${uid}`));
  const senderName = String(sender?.displayName ?? 'New message').slice(0, 60);
  const preview = String(b.preview ?? '').slice(0, 160);
  const recipients = members.filter((m) => m !== uid);
  const mentions = (Array.isArray(b.mentions) ? b.mentions : []).filter((m) => members.includes(m)).slice(0, 50);

  const accessToken = await token();
  const fcm = (message: Record<string, unknown>) =>
    fetch(`https://fcm.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/messages:send`, {
      method: 'POST',
      headers: { authorization: `Bearer ${accessToken}`, 'content-type': 'application/json' },
      body: JSON.stringify({ message }),
    });

  if (chat?.type === 'group') {
    // One request per message: members subscribe to a topic whose name embeds
    // a members-only secret. The sender's own device ignores its echo.
    const secret = String(chat.topicSecret ?? '');
    if (!/^[\w-]{16,64}$/.test(secret)) return json({ sent: 0 });
    const res = await fcm({
      topic: `g_${b.chatId}_${secret}`,
      data: {
        type: 'message', chatId: b.chatId, messageId: b.messageId, senderId: uid, senderName, preview,
        kind: String(b.kind ?? 'text'), chatType: 'group', chatName: String(chat.name ?? 'Group').slice(0, 64),
        mentions: mentions.join(','),
      },
      android: { priority: 'HIGH', ttl: '86400s' },
    });
    return json({ sent: res.ok ? 1 : 0 });
  }
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
      const invite = url.pathname.match(/^\/j\/([A-Za-z0-9]{10,32})$/);
      if (request.method === 'GET' && invite) return invitePage(invite[1]);
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
