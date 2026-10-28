<p align="center">
  <img src="assets/brand/icon_1024.png" width="120" alt="Arnav Chat logo" />
</p>

<h1 align="center">Arnav Chat</h1>

<p align="center">
  A fast, private, beautifully animated messenger for Android — free to run, built with Flutter.
</p>

<p align="center">
  <a href="https://github.com/Arnav-Dugad/arnav-chat/releases/latest/download/arnav-chat-universal.apk">
    <img src="https://img.shields.io/badge/Download-APK-2350E6?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" height="48" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/Arnav-Dugad/arnav-chat/releases/latest"><img src="https://img.shields.io/github/v/release/Arnav-Dugad/arnav-chat?color=27C1D9" alt="Latest release" /></a>
  <a href="https://github.com/Arnav-Dugad/arnav-chat/actions/workflows/ci.yml"><img src="https://github.com/Arnav-Dugad/arnav-chat/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
</p>

---

## Screenshots

| Chats | Conversation | Context menu | Settings |
|:---:|:---:|:---:|:---:|
| _coming soon_ | _coming soon_ | _coming soon_ | _coming soon_ |

## Features

**Messaging**
- 1:1 chats with text, emoji, photos, video, voice notes, files and link previews
- Reply, forward, edit (marked *edited*), delete for me / for everyone, copy, star
- Reactions, read receipts (✓ / ✓✓ / read), typing indicator, online & last seen
- Offline-first: messages queue with a clock icon and send automatically when back online
- Find people by **@username** or by scanning a **QR code**
- Push notifications with inline reply and per-chat grouping

**Design**
- Apple-like glass UI: frosted bars, sheets and menus, continuous-corner squircles
- Light / dark themes and six accent colours; Inter typography; Phosphor icons
- Spring animations everywhere — logo-morph launch, hero transitions, swipe actions,
  swipe-to-reply, iMessage-style context menu, double-tap heart, particle delete,
  hold-to-record voice notes with slide-to-cancel and lock — and it respects *reduce motion*

**Updates**
- The app checks GitHub Releases daily, downloads the right APK for your device,
  verifies its SHA-256 checksum and hands it to the Android installer

## Architecture

```
lib/
  app/          router, root widget
  core/         design system (tokens, glass, motion), widgets, platform interfaces
  data/         models, Drift cache, Firestore/RTDB/Worker clients, repositories
  features/     auth, onboarding, chats, chat, people, settings, notifications, update
worker/         Cloudflare Worker (TypeScript): signed uploads + FCM push
firebase/       Firestore & RTDB security rules + emulator tests
```

| Concern | Service (free tier) |
|---|---|
| Auth | Firebase Auth (Google, email) |
| Chats, messages, profiles | Cloud Firestore (+ offline persistence) |
| Presence & typing | Firebase Realtime Database (`onDisconnect`) |
| Local cache | Drift (SQLite) — the UI only reads from here |
| Media | Cloudinary, **signed** uploads (signature from the Worker) |
| Push | FCM HTTP v1, sent by the Worker after verifying the sender is a chat member |

**Quota-friendly by design:** one listener for the chat list and one for the open chat,
both resuming from an `updatedAt` cursor so reconnects only read changed documents;
history is paged 30 at a time and cached forever; each send is a single batched write
(message + denormalised `lastMessage`). The message body sits in a versioned payload
envelope (`v`, `enc`) so end-to-end encryption can be added without a data migration.

## Setup

Prerequisites: Flutter (stable), Node 20+, Java 17+, `firebase`, `flutterfire`, `wrangler`.

```bash
# 1. Firebase config (generated, git-ignored)
flutterfire configure --project=<your-project> --platforms=android,web --android-package-name=com.arnav.chat

# 2. App config (git-ignored)
cp env/app.example.json env/app.json      # fill WORKER_URL and GOOGLE_SERVER_CLIENT_ID

# 3. Code generation + run
flutter pub get
dart run build_runner build
flutter run --dart-define-from-file=env/app.json
```

**Firebase console:** enable Authentication → Google and Email/Password, create the
Realtime Database, then deploy rules: `firebase deploy --only firestore,database`.

**Worker** (`worker/`):

```bash
npm --prefix worker install
cd worker
npx wrangler secret put FIREBASE_SERVICE_ACCOUNT < service-account.json
npx wrangler secret put CLOUDINARY_API_KEY
npx wrangler secret put CLOUDINARY_API_SECRET
npx wrangler deploy
```

**Tests**

```bash
flutter analyze && flutter test
npm --prefix worker test
firebase emulators:exec --only "firestore,database" --project demo-arnav-chat "npm --prefix firebase/tests run vitest"
```

## Releasing

```bash
dart run tool/bump_version.dart patch   # bumps versionName and always increments versionCode
git commit -am "Release v1.0.1" && git tag v1.0.1 && git push origin main v1.0.1
```

The **Release** workflow builds signed per-ABI and universal APKs, publishes them with
`checksums.txt` and auto-generated notes. To force everyone onto a minimum version, raise
`min_version` in [`version.json`](version.json).

Required repository secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `GOOGLE_SERVICES_JSON`, `FIREBASE_OPTIONS_DART`,
`APP_ENV_JSON` (all base64 where they are files).

## Roadmap

- **Phase B** — groups, pinned messages, polls, search, media gallery, folders, Saved Messages, wallpapers
- **Phase C** — stories, disappearing & scheduled messages, synced drafts, app lock, full privacy controls
- **Later** — voice/video calls (WebRTC), end-to-end encryption, web & desktop

---

Icons: [Phosphor](https://phosphoricons.com) (MIT). Font: [Inter](https://rsms.me/inter) (OFL).
