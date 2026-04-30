# 🎙️ Bantera — iOS Language Learning App

> **Practice speaking a new language by repeating cues from real videos.**
> Record yourself, compare your pronunciation side-by-side, and improve with every session.

[![App Store](https://img.shields.io/badge/App_Store-Download-blue?logo=apple&logoColor=white)](https://apps.apple.com/app/id6761799720)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-%5E3.11-0175C2?logo=dart)
![iOS](https://img.shields.io/badge/iOS-18%2B-black?logo=apple)
![Localization](https://img.shields.io/badge/Localization-EN%20%7C%20JA%20%7C%20KO%20%7C%20ZH-brightgreen)

---

## 📱 Download

[**Download on the App Store →**](https://apps.apple.com/app/id6761799720)

---

## 🔗 Related Repositories

| Repo                                                                 | Description                                      |
| -------------------------------------------------------------------- | ------------------------------------------------ |
| **This repo**                                                        | Flutter iOS app (you are here)                   |
| [**bantera-backend**](https://github.com/lisenhuang/bantera-backend) | .NET REST API backend powering `api.bantera.app` |
| [**bantera-website**](https://github.com/lisenhuang/bantera-website) | Next.js dashboard / website                      |

---

## ✨ Feature Highlights

| Feature                             | Description                                                         |
| ----------------------------------- | ------------------------------------------------------------------- |
| 🎬 **Video Practice**               | Browse community videos, pick a cue, and practice speaking it       |
| 🎙️ **Audio Recording & Comparison** | Record yourself and compare your pronunciation against native audio |
| 🤖 **AI Audio Generation**          | Generate dialogue audio from custom text using AI                   |
| 🌐 **On-Device Translation**        | Instant translations via Apple's Translation framework (iOS 18+)    |
| 🗣️ **On-Device Transcription**      | Speech-to-text via Apple's SpeechTranscriber API (iOS 26+)          |
| 💬 **Language Exchange Chat**       | Chat with native speakers directly in-app                           |
| 🔖 **Saved Cues**                   | Bookmark cues for focused review sessions                           |
| 📤 **Video Upload**                 | Upload your own videos to share with the community                  |
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
│                 NATIVE BRIDGES (iOS)                 │
│   MethodChannel: bantera/video_processing            │
│   MethodChannel: bantera/translation                 │
│   Apple SpeechTranscriber · AVFoundation             │
│   Apple Translation Framework                        │
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
│   ├── translation_service.dart     # iOS native translation bridge
│   ├── video_processing_service.dart# iOS native transcription bridge
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

Features are conditionally enabled based on the installed iOS version, detected at runtime via a native bridge:

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
- Xcode 16+ with iOS 18 simulator or device
- CocoaPods

```bash
# Install dependencies
flutter pub get
cd ios && pod install && cd ..

# Run on simulator
flutter run

# Build for distribution
flutter build ios --release
```

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

_README last updated: 2026-04-30_
