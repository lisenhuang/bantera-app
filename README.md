# 🎙️ Bantera: iOS & Android Language Learning App

> **Practice speaking a new language by repeating cues from real videos.**
> Record yourself, compare your pronunciation side-by-side, and improve with every session.

[![App Store](https://img.shields.io/badge/App_Store-Download-blue?logo=apple&logoColor=white)](https://apps.apple.com/app/id6761799720)
[![Android APK](https://img.shields.io/badge/Android-Download_APK-3DDC84?logo=android&logoColor=white)](https://bantera.app/download)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-%5E3.11-0175C2?logo=dart)
![iOS](https://img.shields.io/badge/iOS-18%2B-black?logo=apple)
![Localization](https://img.shields.io/badge/Localization-EN%20%7C%20JA%20%7C%20KO%20%7C%20ZH-brightgreen)

---

## 📱 Download

Bantera is available on **iOS through the App Store** and **Android as a signed APK from the Bantera website**.

- **iOS:** [Download on the App Store](https://apps.apple.com/app/id6761799720) (iOS 18+).
- **Android:** [Download page](https://bantera.app/download) or [download the APK directly](https://bantera.app/bantera.apk) (Android 7.0+, ARM64 devices).

For Android, open the downloaded APK and allow installation from your browser or file manager when prompted.

---

## 🔗 Related Repositories

| Repo                                                                 | Description                                      |
| -------------------------------------------------------------------- | ------------------------------------------------ |
| **This repo**                                                        | Flutter iOS and Android app (you are here)                   |
| [**bantera-backend**](https://github.com/lisenhuang/bantera-backend) | .NET REST API backend powering `api.bantera.app` |
| [**bantera-website**](https://github.com/lisenhuang/bantera-website) | Next.js dashboard / website                      |

---

## ✨ Feature Highlights

| Feature                             | Description                                                         |
| ----------------------------------- | ------------------------------------------------------------------- |
| 🎬 **Video Practice**               | Browse community videos, pick a cue, and practice speaking it       |
| 🎙️ **Audio Recording & Comparison** | Record yourself and compare your pronunciation against native audio |
| 🤖 **AI Audio Generation**          | Generate dialogue audio from custom text using AI                   |
| 🌐 **On-Device Translation**        | On-device translation via Apple Translation (iOS) and Google ML Kit (Android)    |
| 🗣️ **On-Device Transcription**      | Speech-to-text via Apple's SpeechTranscriber API (iOS 26+)          |
| 💬 **Language Exchange Chat**       | Chat with native speakers directly in-app                           |
| 🔖 **Saved Cues**                   | Bookmark cues for focused review sessions                           |
| 📤 **Video Upload**                 | Upload your own videos to share with the community                  |
| 📊 **iOS Practice Widget**         | Today’s spoken/listened words and one-tap access to Bantera AI; [setup and design](docs/ios-practice-widget.md) |
| 🌙 **Dark Mode**                    | Full light/dark theme support                                       |
| 🌏 **i18n**                         | UI available in English, Japanese, Korean, and Chinese              |

---

## 🏗️ Architecture

A clean, layered architecture with clear separation of concerns across three layers:

```
┌──────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                  │
│   Screens · Widgets · Navigation · Theme · i18n       │
│   30 screens across Auth, Discover, Create, Practice  │
│   Profile, Chat, and Dev flows                        │
└───────────────────────┬──────────────────────────────┘
                        │ ChangeNotifier / ListenableBuilder
┌───────────────────────▼──────────────────────────────┐
│                     CORE LAYER                        │
│   Singleton Notifiers — global reactive state         │
│   AuthSession · UserProfile · Settings · Theme        │
│   GenerationJob · ProfileStats · AppResume            │
└────────────┬──────────────────────┬───────────────────┘
             │                      │
┌────────────▼────────┐  ┌──────────▼────────────────────┐
│  INFRASTRUCTURE     │  │  INFRASTRUCTURE               │
│  (Remote)           │  │  (Local)                      │
│                     │  │                               │
│  auth_api_client    │  │  Drift/SQLite ORM             │
│  REST API client    │  │  local_practice_repository    │
│  JWT + refresh      │  │  saved_cue_repository         │
│  1,552 LOC          │  │  SharedPreferences stores     │
└─────────────────────┘  └───────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────┐
│             NATIVE BRIDGES (iOS / Android)            │
│   MethodChannel: bantera/video_processing            │
│   MethodChannel: bantera/translation                 │
│   Apple SpeechTranscriber · AVFoundation             │
│   Apple Translation Framework                       │
│   Android SpeechRecognizer · Google ML Kit           │
└─────────────────────────────────────────────────────┘
```

---

## 🗂️ Project Structure

```
lib/
├── main.dart                        # App entry, provider wiring, routing
├── core/                            # Global reactive state (ChangeNotifiers)
│   ├── auth_session_notifier.dart
│   ├── user_profile_notifier.dart
│   ├── settings_notifier.dart
│   ├── generation_job_notifier.dart
│   └── theme.dart
├── domain/
│   └── models/models.dart           # Pure Dart domain models
├── infrastructure/                  # Services, API clients, repositories
│   ├── auth_api_client.dart         # REST API client (~1,552 LOC)
│   ├── local_practice_database.dart # Drift ORM schema & DAOs
│   ├── translation_service.dart     # iOS / Android native translation bridge
│   ├── video_processing_service.dart# iOS / Android native media bridge
│   └── ...
├── presentation/                    # Screens and widgets (~30 screens)
│   ├── auth/
│   ├── onboarding/
│   ├── discover/
│   ├── create/
│   ├── practice/
│   ├── chats/
│   ├── profile/
│   └── shared/
└── l10n/                            # ARB localization files (EN/JA/KO/ZH)
```

---

## 🔑 Technical Deep Dives

### Bantera AI: web search on the device

Bantera AI can call `search_web(query)` during real-time audio calls and streamed
voice-message replies. **No DuckDuckGo API key is required.** The app makes a
direct HTTPS GET request to `https://html.duckduckgo.com/html/?q=<encoded-query>`
and parses the returned search-results HTML with Dart's `html` package. This is
HTML page parsing, not a dedicated DuckDuckGo search API or Gemini's built-in
Google Search grounding.

1. Gemini requests the custom `search_web` function through the existing backend
   WebSocket relay.
2. The app searches DuckDuckGo directly and extracts up to five titles, HTTPS
   links and short excerpts. It does not automatically fetch the linked pages.
3. The app sends these results back through the relay so Gemini can answer.
   The chat bubble displays tappable source links alongside the response.
   Tapping a link opens an in-app browser so you can return directly to the chat.

The backend registers and relays the tool; it does not execute the search.
No search API secret, Bantera authentication headers or cookies are sent to
DuckDuckGo. Existing Gemini credentials are still required on the backend for
the AI conversation. DuckDuckGo receives the query and the device's network
connection; the query and returned excerpts also pass through Bantera's backend
to Gemini. Source cards are saved in the device's chat history.

**Reliability:** DuckDuckGo documents its [non-JavaScript search interface](https://duckduckgo.com/duckduckgo-help-pages/features/non-javascript),
but this integration depends on its HTML layout and has no search API service
guarantee. Markup changes, rate limits, bot challenges or network failures can
make search unavailable. The app returns an unavailable result instead of
bypassing challenges. It limits uncached requests to four per minute, caches
successful results in memory for five minutes, and uses an eight-second timeout.
Search excerpts are treated as untrusted content, not instructions or full articles.

Implementation: [`AiWebSearch`](lib/infrastructure/ai/ai_web_search.dart).
See [device web-search design](docs/ai-device-web-search.md) for protocol,
privacy, bounds and release requirements. No additional search configuration or
environment variable is needed.

### 🎙️ Practice Player — Word-Level Highlight Sync

The core of the app. The practice player maps each character in a transcript to a millisecond timestamp, enabling word-by-word highlight sync during playback. Unicode-aware tokenization handles CJK and apostrophe-contracted words:

```dart
RegExp _kWordTokenRe = RegExp(
  r"[\p{L}\p{N}]+(?:[''ʼ][\p{L}\p{N}]+)*",
  unicode: true,
);
```

The player supports multiple modes (full cue vs. short cue), play-all with configurable pause strategies, and simultaneous audio recording for comparison.

---

### 🔄 JWT Auth with Concurrent Refresh Deduplication

The API client handles silent token refresh automatically. Multiple in-flight requests that fail with 401 share a single refresh attempt — only one refresh hits the server regardless of concurrency:

```
Request A ──► 401 ──► [refresh pending] ──► retry with new token ──► ✅
Request B ──► 401 ──┘ (awaits shared refresh future)               ──► ✅
Request C ──► 401 ──┘                                              ──► ✅
```

JWT subject extraction is used to scope cache keys per user, preventing stale state across account switches.

---

### 📱 iOS Version-Gated Features

On iOS, Apple-specific features are conditionally enabled based on the installed system version, detected at runtime via a native bridge. Android uses its own native implementations; the table below applies only to iOS:

| iOS Version | Feature Unlocked                                            |
| ----------- | ----------------------------------------------------------- |
| iOS 18+     | Apple Translation Framework (on-device, privacy-preserving) |
| iOS 18+     | Create tab (video upload, AI audio generation)              |
| iOS 26+     | On-device speech transcription (SpeechTranscriber)          |

```dart
bool get supportsBuiltInTranslation    => osVersion >= 18;
bool get supportsCreateTabOnApple      => osVersion >= 18;
bool get supportsOnDevicePracticeVideo => osVersion >= 26;
```

---

### 🗄️ Local Database with Drift (SQLite ORM)

A local SQLite database (via Drift) persists practice sessions, video metadata, and attempt history per user. Transactions ensure atomicity for multi-table writes. Code-generated DAOs keep data access type-safe.

---

### 🌐 Localization — 4 Languages, ~450 Keys Each

Full UI localization using Flutter's ARB pipeline across English, Japanese, Korean, and Simplified/Traditional Chinese. Language selection is independent of the learning language — a user can study Japanese while reading the UI in Korean.

---

## 📦 Key Dependencies

| Category        | Package                                           | Purpose                               |
| --------------- | ------------------------------------------------- | ------------------------------------- |
| **Media**       | `video_player` · `record` · `audioplayers`        | Video/audio playback and recording    |
| **Database**    | `drift` · `sqlite3_flutter_libs`                  | Type-safe local ORM                   |
| **Images**      | `cached_network_image` · `flutter_image_compress` | Caching and upload optimization       |
| **Permissions** | `permission_handler`                              | Microphone, camera, photos            |
| **Auth**        | `sign_in_with_apple`                              | Apple Sign-In                         |
| **Network**     | `connectivity_plus`                               | Reachability and error classification |
| **UX**          | `wakelock_plus` · `in_app_review` · `share_plus`  | Screen lock, ratings, sharing         |
| **i18n**        | `flutter_localizations` · `intl`                  | Localization pipeline                 |

---

## 🌐 REST API Surface

All communication goes through a typed API client.

| Domain       | Endpoints                                                 |
| ------------ | --------------------------------------------------------- |
| **Auth**     | Login, register, Apple Sign-In, silent token refresh      |
| **Profile**  | Fetch/update profile, upload avatar                       |
| **Videos**   | Public feed (paginated), upload, delete, fetch transcript |
| **Practice** | Submit corrected transcript, compare attempts             |
| **AI Audio** | Generate dialogue audio, poll job status                  |
| **Saved**    | Save/remove videos; save/remove individual cues           |
| **Stats**    | Fetch user statistics (views, practice counts)            |
| **Catalog**  | Supported learning languages and translation languages    |

---

## 🧩 State Management

Custom singleton `ChangeNotifier`s — no external state library. Each notifier owns a discrete slice of app state and persists its data independently:

```
AuthSessionNotifier     ──► JSON file (tokens + refresh rotation)
UserProfileNotifier     ──► JSON file (profile, avatar URL)
SettingsNotifier        ──► JSON file (theme, locale, notifications)
GenerationJobNotifier   ──► In-memory (polled from API)
LocalPracticeRepository ──► Drift/SQLite
SavedCueRepository      ──► Drift/SQLite
```

Screens subscribe via `ListenableBuilder` — no `setState` outside of ephemeral local UI.

---

## 🏁 Getting Started

**Requirements:**

- Flutter SDK `^3.x` with Dart `^3.11`
- **iOS development:** macOS, Xcode with the required iOS SDK, an iOS 18+ simulator or device, and CocoaPods.
- **Android development:** Android SDK tooling and an Android emulator or device (minimum API 24).

```bash
# Install shared Flutter dependencies
flutter pub get

# List available devices, then run on iOS or Android
flutter devices
flutter run -d <device-id>
```

### iOS build

```bash
cd ios && pod install && cd ..
flutter build ios --release
```

### Android APK build and website release

Release signing must be configured locally in `android/key.properties`. Keep that file and the keystore out of Git.

```bash
# Build the signed ARM64 APK
flutter build apk --release --split-per-abi --target-platform android-arm64

# Or build and copy the APK plus release metadata to the sibling website repo
./scripts/publish_android.sh
```

The script prepares `public/bantera.apk`, `public/android-release.json`, and `src/lib/android-release.ts` in `../website`. Commit and push those three files in the website repository, then deploy the website to make the download available. Before publishing a new app release, bump both the version name and build number in `pubspec.yaml`.

---

## 📊 Codebase Stats

| Metric                | Value              |
| --------------------- | ------------------ |
| Dart source files     | ~70                |
| Screens               | 30                 |
| Localization keys     | ~450 per language  |
| Languages             | 4 (EN, JA, KO, ZH) |
| API endpoints covered | ~25                |

---

## 📄 License

Private — all rights reserved.

---

_README last updated: 2026-09-29_

### Device-side AI image replies (2.6.1)

Image replies reuse the **existing** `search_web(query)` tool and deployed relay.
No backend change, deployment, new endpoint or new Gemini function is required.
The app includes a transient capability note in each streaming session's context:
Gemini requests `search_web` with `images: <public topic>` for pictures, while
ordinary queries keep using DuckDuckGo. This note is not a chat message, is not
saved in local history, does not count as learner speech, and never completes a
user turn by itself. The multipart fallback has no device tools and gets no note.

The phone removes the prefix, searches the public Wikimedia Commons Action API,
downloads up to two raster previews per search (four per reply), validates their
size/dimensions and saves them beside account-specific local AI history. Tap a
card to enlarge and save/share the image file. Source links open in-app and retain
creator/licence attribution. Clearing AI history deletes its image files.

No search API key is needed. Queries go directly from the phone to Wikimedia,
and image bytes directly from Wikimedia to the phone. The existing Gemini relay
still carries tool requests and result metadata (titles, URLs and attribution),
as it does for ordinary web search; image files and local file paths are never
uploaded. Gemini receives metadata, not pixels, and must not claim to have
inspected the picture. This is device-executed internet search, not offline AI.

HTTP uses fixed Wikimedia API/image hosts, no app authentication headers or
redirects, an eight-second budget, four searches/minute, a 3 MiB/file ceiling and
bounded decoded dimensions. Cancelled sessions cannot attach late downloads.
Image failures do not fail the voice reply. The implementation uses Wikimedia's
[Imageinfo API](https://www.mediawiki.org/wiki/API:Imageinfo).
