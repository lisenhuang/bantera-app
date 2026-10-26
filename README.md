# 🎙️ Bantera: iOS & Android Language Learning App

[![CI](https://github.com/lisenhuang/bantera-app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/lisenhuang/bantera-app/actions/workflows/ci.yml)
[![Contributing](https://img.shields.io/badge/Contributing-guide-blue)](CONTRIBUTING.md)
[![Security policy](https://img.shields.io/badge/Security-reporting-blue)](SECURITY.md)

> **Practice speaking a new language by repeating cues from real videos.**
> Record yourself, compare your pronunciation side-by-side, and improve with every session.

[![App Store](https://img.shields.io/badge/App_Store-Download-blue?logo=apple&logoColor=white)](https://apps.apple.com/app/id6761799720)
[![Android APK](https://img.shields.io/badge/Android-Download_APK-3DDC84?logo=android&logoColor=white)](https://bantera.app/download)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-%5E3.11-0175C2?logo=dart)
![iOS](https://img.shields.io/badge/iOS-18%2B-black?logo=apple)
![Localization](https://img.shields.io/badge/Localization-EN%20%7C%20JA%20%7C%20KO%20%7C%20ZH-brightgreen)

## Engineering quality

Maintained by [@lisenhuang](https://github.com/lisenhuang), with reproducible local checks, regression tests, and documented review expectations.

CI pins Flutter 3.41.9, restores `pubspec.lock`, fails on analyzer errors or warnings, runs all Flutter unit/widget tests with LCOV coverage, compiles an Android debug APK, and runs the native Kotlin tests. Analyzer informational lints remain visible but do not fail the build. Coverage is available as an artifact, not a claimed coverage target. iOS compilation and native audio behavior are separate checks; CI does not exercise a physical phone.

| Repository | Latest `main` CI |
| --- | --- |
| [app](https://github.com/lisenhuang/bantera-app) | [![CI](https://github.com/lisenhuang/bantera-app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/lisenhuang/bantera-app/actions/workflows/ci.yml) |
| [backend](https://github.com/lisenhuang/bantera-backend) | [![CI](https://github.com/lisenhuang/bantera-backend/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/lisenhuang/bantera-backend/actions/workflows/ci.yml) |
| [website](https://github.com/lisenhuang/bantera-website) | [![CI](https://github.com/lisenhuang/bantera-website/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/lisenhuang/bantera-website/actions/workflows/ci.yml) |

The badges show real workflow results, including failures. Test reports are retained for 14 days. [Contribution guidance](CONTRIBUTING.md), [maintainer ownership](.github/CODEOWNERS), [dependency update configuration](.github/dependabot.yml), and [private security reporting](SECURITY.md) describe how changes are maintained. CI does not deploy production releases.

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

### Bantera AI: streamed audio, playback and waveforms

Bantera AI voice-message replies arrive as small audio chunks. The app starts
playing the available chunks while the AI continues generating and sending the
rest of the response. It does not wait for a complete audio file before speaking.

Receiving and playback finish independently:

- **Receiving finishes** when the server sends the response-complete event. The
  app then assembles and saves the received audio as a WAV file.
- **Playback finishes** when the phone has played all queued audio. This can
  happen later than receiving finishes; the gap varies between responses.
- **The waveform appears** after the complete reply is saved and the app has
  analysed its audio. The current implementation does not build a waveform
  progressively from incoming chunks, so it can appear near the end of speech.
  It does not deliberately wait for playback to finish.

Starting a new recording stops the previous reply's playback, while its committed
stream continues receiving and saving the response. Pausing playback also allows
reception to continue. The voice bar stays still when playback is stopped or
paused, even if more audio is arriving.

A delay before the waveform appears can include AI generation, transmission,
file saving and queued waveform analysis. Timing measurements are needed to
identify the cause of a particular delay; it is not necessarily slow downloading.

Implementation: [voice stream](lib/infrastructure/ai/ai_voice_stream.dart),
[reply controller](lib/presentation/chats/ai/ai_chat_controller.dart), and
[waveform analysis](lib/infrastructure/audio_waveform.dart).

### 🔊 Fixing AI speaker echo on iPhone

[**How we investigated and fixed AI self-interruption**](docs/ios-echo-investigation.md)
explains the cause, physical iPhone measurements, and the fix with a short
diagram and results table. Includes the interruption tradeoff and regression checks.

### Bantera AI: web search on the device

Bantera AI can call `search_web(query)` during real-time audio calls and streamed
voice-message replies. **No search API key is required.** The app makes a direct
HTTPS GET request to `https://html.duckduckgo.com/html/?q=<encoded-query>`.
If that fails or returns no usable results, the phone tries
`https://www.bing.com/search?q=<encoded-query>&adlt=strict`. Both providers run
on the device, with returned HTML parsed using Dart's `html` package. This is
HTML page parsing, not a dedicated search API or Gemini's built-in Google Search
grounding.

1. Gemini requests the custom `search_web` function through the existing backend
   WebSocket relay.
2. The app searches directly using DuckDuckGo, then Bing if needed, and extracts up to five titles, HTTPS
   links and short excerpts. It does not automatically fetch the linked pages.
3. The app sends these results back through the relay so Gemini can answer.
   The chat bubble displays tappable source links alongside the response.
   Tapping a link opens an in-app browser so you can return directly to the chat.

The backend registers and relays the tool; it does not execute the search.
No search API secret, Bantera authentication headers or cookies are sent to
either search provider. Existing Gemini credentials are still required on the backend for
the AI conversation. Each contacted provider receives the query and the device's network
connection; the query and returned excerpts also pass through Bantera's backend
to Gemini. Source cards are saved in the device's chat history.

**Reliability:** DuckDuckGo documents its [non-JavaScript search interface](https://duckduckgo.com/duckduckgo-help-pages/features/non-javascript),
but this integration depends on its HTML layout and has no search API service
guarantee. Markup changes, rate limits, bot challenges or network failures can
make search unavailable. The app returns an unavailable result instead of
bypassing challenges. It limits uncached requests to four per minute, caches
successful results in memory for five minutes, and gives each provider five seconds
(ten seconds total). Ending the call cancels the active search and prevents a
fallback from starting. Bing also depends on its public HTML layout and can be
unavailable; no challenges are bypassed.
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

This section describes the original Wikimedia implementation. Version 2.10.0
extends it to web-wide image search; see the current behaviour below.

Image replies reuse the **existing** `search_web(query)` tool and deployed relay.
No backend change, deployment, new endpoint or new Gemini function is required.
The app includes a transient capability note in each streaming session's context:
Gemini requests `search_web` with `images: <public topic>` for pictures, while
ordinary queries use DuckDuckGo with an on-device Bing fallback. This note is not a chat message, is not
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

### Conversation timing (2.7.0)

AI context includes each saved message's UTC `createdAt`, across voice messages
and real-time calls. Failed/unsent messages and synthetic capability notes do not
become fresh interactions. The history budget prioritises the newest turns so
long histories cannot drop the last interaction. Clearing history clears timing
context too. Timestamps are sent with the existing bounded history; they add no
server-side conversation storage. Backend 1.5.0 compares them with current server
time and the learner's time zone to guide natural continuation or a welcome back.
Old servers ignore the additive timestamp field.

New messages also retain their original device time zone and UTC offset. The
coach can interpret a dated future plan and ask whether it happened, without
assuming attendance. A changed time zone is a conversational cue, not proof of
travel or location. Historical zones missing from older messages remain unknown;
clearing history removes these details. No automatic reminders are inferred.

## AI rolling memory (2.8.0)

AI chat keeps a local, account-isolated rolling summary plus the newest 20 messages for fresh sessions. Background summarisation sends the previous summary and bounded batches of older transcripts to the backend's stateless text-model endpoint. The complete chat and summary remain on this device; Gemini receives context to process it. Atomic summary replacement preserves the last successful checkpoint on network failure. Clear History removes the summary and rotates the device conversation ID, including invalidating pending writes. An eligible provider session can resume for up to two hours without replaying history; fresh sessions fall back to the summary/recent messages. Time and timezone still accompany each message. Session resumption uses separate voice-message/call modes and resets when learning/profile/model settings change.

In 2.8.1, AI transcripts suppress the exact internal historical-timing marker produced by older history transport, including during streamed delivery and when restoring saved bubbles. Human transcripts are unchanged; existing audio recordings are not altered. The matching backend fix sends history as private background context, not assistant speech.

Leaving AI chat during a voice reply checkpoints the visible input/output transcriptions and received reply audio before closing the stream. Reopening waits for pending writes for the same local account, so the partial bubble remains available without a false send error. Navigation may stop the remaining download; it never removes the received portion.

### iOS live-call audio routing (2.8.3)

In-app AI calls and CallKit callbacks both use `BanteraPhoneAudio`, with capture
and AI playback passing through the same Apple VoiceProcessingIO audio unit.
Voice processing remains enabled for receiver, speaker and headset routes; the
system uses the rendered output as its acoustic echo-cancellation reference.
Do not switch live calls back to the default-mode `prefersEchoCancelledInput`
path or use a separate media player for live AI output.

The session uses `playAndRecord` / `voiceChat` with Bluetooth HFP and **without**
`defaultToSpeaker`. The in-app speaker button uses a transient output override;
turning it off restores the normal receiver/headset route. Route notifications
update the UI and lock-screen activity from the actual hardware route, and route
switch failures do not stop an otherwise healthy call. CallKit retains ownership
of activation and its route picker. Voice-message playback remains playback-only.

References: [Apple speakerphone routing](https://developer.apple.com/library/archive/qa/qa1754/_index.html),
[Apple voice processing](https://developer.apple.com/documentation/avfaudio/avaudiosession/mode-swift.struct/voicechat),
[WebRTC's iOS duplex audio design](https://webrtc.googlesource.com/src/webrtc/+/f54860e9ef0b68e182a01edc994626d21961bc4b/modules/audio_device/ios/audio_device_ios.h).
Physical receiver output and acoustic echo performance require user verification;
builds and mocked route tests cannot establish those acoustic results.

### Chat formatting and audio waveforms (2.9.0)

AI reply text and on-demand translations render selectable Markdown (emphasis,
lists, headings, quotes and code blocks). Web links use the existing in-app
browser and URL validation. Markdown image syntax does not load arbitrary URLs;
images continue through the existing device image-search/download cards.
Known JSON punctuation escapes in AI prose are repaired when streaming and when
loading saved messages, while literal escapes inside code remain intact.

AI, direct and group voice messages share a waveform timeline with played/unplayed
colours. It measures 64 peak-amplitude buckets from the local audio file. PCM16
WAV analysis runs in a Dart isolate; compressed files use system AVAudioFile on
iOS and MediaExtractor/MediaCodec on Android, without an extra codec library or
an audio-session change. Decoding is serial, bounded and cached for up to 128
files in memory. Visible human chat audio uses the existing authenticated audio
cache. While a file is still arriving or cannot be decoded, the ordinary timeline
remains usable. No waveform data is uploaded.

Implementation references: [Flutter Markdown](https://pub.dev/packages/flutter_markdown_plus),
[Apple AVAudioFile](https://developer.apple.com/documentation/avfaudio/avaudiofile),
[Android MediaCodec](https://developer.android.com/reference/android/media/MediaCodec).

### Live-call interruption correction (2.9.1)

Microphone amplitude now controls only local recording boundaries. It never sends
clock/text packets during a live turn: Gemini `clientContent` interrupts ongoing
generation even when `turnComplete` is false. Speech input still streams through
iOS VoiceProcessingIO and Gemini's low-sensitivity VAD, so real spoken interruptions
remain possible. Each voice message and initial/reconnected call retains its time
context; the server's `get_current_time` tool supplies current time for reminders.
This app-side correction works with the existing deployed backend. Backend 1.12.3
also retains old clients' clock packets as tool metadata without forwarding them.

Reference: [Gemini clientContent semantics](https://ai.google.dev/api/live#BidiGenerateContentClientContent).

Live input regression: `test/ai_call_clock_test.dart` checks that silence, strong
microphone samples and route events never inject clock text while an AI reply is
active. Microphone frames remain intact, rather than muting capture during playback.

VoiceProcessingIO now uses the activated audio route's actual sample rate. In-app
calls request 48 kHz / 20 ms as preferences, with routing selected before the unit
starts; CallKit keeps control of session activation. Native conversion takes
Gemini's 24 kHz output to the hardware rate and post-processing microphone audio
to 16 kHz on a serial queue. A hardware-rate change rebuilds the unit format and
converts remaining queued audio, preserving playback totals in 24 kHz units.
`AiAudioRateTests` in `ios/RunnerTests/RunnerTests.swift` cover fragmented and large
packets, route-rate changes, interruptions and converter resets without using
audio hardware. Diagnostics report both session and unit sample rates plus the
voice-processing bypass state; an enabled state alone does not establish acoustic
echo suppression. Physical checks need a known playback reference and a quiet
microphone baseline, without saving or uploading microphone recordings.

References: [Apple voice processing](https://developer.apple.com/videos/play/wwdc2023/10235/),
[WebRTC VoiceProcessingIO setup](https://webrtc.googlesource.com/src/+/refs/heads/main/sdk/objc/native/src/audio/voice_processing_audio_unit.mm).

### AI chat navigation and system callbacks (2.9.2)

AI chat taps, widget links and reminder links share one route coordinator. It
reserves the route before its first frame, reuses an existing conversation,
waits for an interactive back gesture to finish and waits for a popped route's
removal before reopening. History loading/sync starts after the entrance
transition; conversation bubbles are built lazily at the newest message, with
stable message keys as streamed replies arrive. The reported intermittent
half-transition was not conclusively reproduced, so these corrections address
observable navigation races and unnecessary work without claiming a Flutter
engine root cause or changing the global page animation.

iOS AI callbacks have a separate audio-only CallKit provider. Human calls retain
their existing video-capable provider. AI call metadata cannot request video,
and answering an AI callback never creates an automatic in-app chat overlay.
The controller owns audio and transcript persistence without requiring a chat
widget; CallKit manages activation, mute, hang-up and the actual audio route.
Receiver routing is the default unless iOS selects a headset or the user selects
speaker. CallKit callbacks do not enable the screen wake lock or request new
microphone permission from the background. Opening AI chat manually during a
callback shares that call's controller; ending it returns the page to a normal
conversation controller. The process must run in the background to deliver audio,
but no scene-activation/open-app request is sent by the callback path. The exact
system UI presentation is controlled by iOS.

AI bubble Markdown rendering remains enabled for streamed and saved responses,
including emphasis, lists and code blocks; explicit Markdown requests are sent
as ordinary spoken learner requests. No model rule prohibits Markdown. Markdown
links use the in-app browser and arbitrary Markdown image URLs are not fetched.

Regression coverage: `ai_chat_navigation_test.dart`, `ai_chat_entry_test.dart`,
`ai_chat_screen_test.dart`, `ai_callback_notifier_test.dart`,
`ai_message_markdown_test.dart` and the native CallKit capability test in
`RunnerTests.swift`.

Reference: [Apple on audio CallKit presentation and foregrounding](https://developer.apple.com/forums/thread/798090).

### Web-wide device image search (2.10.0)

AI image requests now search Bing's public image-results page first, across
publisher websites. Wikimedia Commons is the fallback if web previews cannot
be fetched. The same `images:` device-tool contract is used; no image-search
backend endpoint, provider secret or image upload is added. The phone downloads
up to two JPEG/PNG/WebP previews, saves them beside local chat history and shows
the publisher's source link in the in-app browser. The model receives metadata,
not image pixels. Unknown usage rights are labelled as such; public search does
not establish permission to reuse an image.

The public HTML integration needs no API key, but is best-effort and can change
or be unavailable. Captchas/challenges are not bypassed. Requests use strict
search filtering, no account cookies or app credentials, a twelve-second total
budget, four searches per minute, a 3 MiB/file limit and bounded decoded image
dimensions. Every HTTPS connection resolves and pins a public IP address;
private, local and mapped addresses are rejected, including on redirects
(maximum three). Search URLs come from provider metadata, not model-supplied
arbitrary download commands. Source domains and licences from existing Wikimedia
history remain readable. Image failures do not terminate the voice reply.


Verification for 2.10.0: Dart image/navigation/voice/Markdown regression tests
passed; all seven selected native audio/CallKit tests passed. A simulator smoke
check completed twelve rapid open/pop/reopen cycles with 2,000 synthetic messages
and no Flutter errors, then retrieved two JPEG previews from non-Wikimedia
publisher websites through the actual device search code. The normal signed
`lib/main.dart` release was installed and read back as 2.10.0 (344) on the iPhone;
no temporary simulator harness, physical-device launch or phone test was used.


### Locked-screen AI callback startup (2.10.3)

CallKit configures the duplex session before reporting an incoming call. In
`didActivate`, native VoiceProcessingIO starts immediately, keeping capture and
playback in the same echo-cancelled unit while Flutter wakes in the background.
Dart attaches to that running unit without restarting it or deactivating
CallKit's session. A bounded background task covers answer preparation and ends
when audio startup finishes, the call ends, or iOS expires the task.

Early activation events are retained until backend acceptance and history loading
finish; duplicate activation does not start a second stream. No scene activation
or automatic chat navigation is requested. Native startup failures end the call
rather than leaving an apparently connected silent call. Callback diagnostics
record only a correlation ID and technical failure category (acceptance,
activation timeout, or audio startup), never reminder text or recorded audio.

Validation: callback event-order regression tests and iOS builds. Actual locked
screen audio must be verified on a physical iPhone; simulator coverage does not
establish successful CallKit hardware audio.


### Voice startup and silent recordings (2.10.6)

Before opening a Live call, native iOS waits for 400 ms of actual microphone
capture, an output callback and enabled VoiceProcessingIO on a stable route.
This establishes audio readiness, not acoustic convergence (Apple exposes no
public convergence flag). Processing stays monitored during the call. A genuine
route change restarts readiness; routine category notifications do not.

A small native residual-echo guard compares post-VPIO microphone PCM with actual
speaker output. Besides a scaled waveform match, it can verify a short filtered
copy caused by speaker/microphone frequency response. The filter is fitted to
older samples and verified against the new microphone chunk at full 16 kHz;
unexplained speech must pass, including higher-frequency user syllables.

The first audible speaker output after a new route has a bounded **500 ms of
captured audio** startup guard while AEC adapts. Render callbacks running ahead
cannot consume that protection early. It can suppress an overlapping first
syllable during this brief interval; later replies do not rearm it. A route
change invalidates queued microphone buffers before resetting the converter
and echo history, so old speaker audio cannot bypass the guard as receiver input.

No model, binary SDK or new app dependency is bundled. Read-only diagnostics
include the actual route, processing state, readiness, system microphone mode,
and counters for startup-protected and matched-echo frames. They contain no
recorded speech. Synthetic tests establish bounded protection and preservation
of tested user speech, not reliable cancellation in every physical room.

CallKit reserves audio before answering and owns its lifetime. Replacing a
Flutter input listener, finishing an older voice reply or detaching a chat scene
cannot stop that call. Receiver is selected once before presentation; later
startup steps preserve the person's system Speaker choice. Each newly answered
scheduled callback opens a fresh Gemini session, with saved context/reminder
supplied once. A network reconnect within the same callback can resume it.

Voice requests opt into `acceptNoSpeech`. Backend acoustic screening returns
`no_speech` (or HTTP `{noSpeech:true}`) for empty/no-speech recordings before
contacting Gemini. The app discards that recording and pending bubble without
showing an error or awarding word activity. This is a speech detector, not a
perfect classifier of background conversations or music. Older backend/client
combinations retain their existing contract.

Validation covers synthetic echo/double-talk, native readiness, callback event
ordering/lifetime, and persisted silent-recording cleanup. Simulator tests do not
prove locked-screen hardware audio or room acoustics on an iPhone.

### Vocabulary notebook (2.11.0)

Open **Bantera AI → ⋯ → Vocabulary** to search, add, edit, remove or review words.
Each entry has a word/phrase, short meaning, optional example, learning language,
original save timestamp/timezone, edit time and review history counters. The
newest entry and full count are available to AI via `manage_vocabulary` in both
voice-message streaming and live calls. The model must use this device tool and
wait for success before claiming a change. Edit/delete require an exact saved ID;
repeated adds of the same word/language preserve the original entry/date.

Records are account-isolated atomic JSON files beside, not inside, chat history,
under the native backup-excluded AI storage root. Clearing chat history keeps the
notebook. There is no vocabulary database/server sync; requested tool results
pass through the existing Live relay to the model. Uninstalling loses the notebook.
Review dates use simple 1/3/7/14/30-day intervals; these are practice suggestions,
not a claim of mastery. AI can offer a review during a natural pause, at most once
per 24 hours when due words exist. It waits for consent and does not schedule
notifications automatically. The notebook UI supports all 17 app locales.

### Live-call connection and countdown (2.11.1)

The in-app call stays on **Connecting** after the server's `ready` event. The
nine-minute countdown begins with the first non-empty streamed AI audio, not
socket setup or a transcript. Microphone frames can still interrupt the opening
after the transport is ready. Reconnecting preserves the original running clock;
it never grants another nine minutes. Backend 1.14.1 aligns its farewell deadline
with the first streamed audio for a new call.

Quota/expiry/response-timeout controls are handled internally. Failed recovery
uses the existing localised generic error, never a provider message or API-key
detail. Backend technical progress diagnostics contain no conversation content.

### Prompt native CallKit answer completion (2.11.2)

AI callbacks complete `CXAnswerCallAction` immediately after native audio preparation, before waiting for backend acceptance or Flutter history loading. The answering provider is retained as the call owner. This removes an asynchronous startup dependency before iOS can deliver `didActivate`. The notifier still waits for both backend acceptance and audio activation before opening Gemini; rejection closes the native call. Human WebRTC calls retain their existing answer-ready handshake. No key-routing or backend changes are needed.

Validation: eight callback/CallKit event-order tests passed, including early activation during acceptance and rejection after early activation. Device builds compile the Swift change. Locked-screen audio still requires a real callback check on the phone; build/installation success alone does not verify it.

### AI emoji delivery (2.12.0)

Voice messages and live calls advertise `deviceEmojis` and expose `send_emojis`.
When the learner asks for emojis, Gemini sends actual Unicode characters (including
country flags, skin tones and joined sequences) to the device; the app displays
them in the current reply bubble and saves them with local history. These display
attachments are kept separate from spoken transcripts and listening-word counts.
Retries do not duplicate emojis. Requests are bounded to 12 emojis per bubble and
reject text names, URLs and control characters. There are no image downloads, new
packages, search calls or separate model calls.

Requires backend 1.16.0. Older apps do not advertise the capability and keep their
existing voice behaviour. New clients connected to an older backend continue
working but cannot use the emoji tool until the backend is updated.

## Authorised AI key preference

Settings shows “AI key preference” only when the backend grants the signed-in account access to the configured paid Gemini key. Users can select regular keys only, paid fallback, or paid only. The preference is saved on the server and applies to new Gemini requests across lessons and voice chats; it does not restart an existing call. The key itself never reaches the app. Missing permission, older servers and failed permission checks hide the control. Switching accounts discards the previous account’s settings state.

### Recoverable AI work

Conversation summaries and transcript corrections use saved backend jobs with
short submission/status requests. The previous summary remains available until
a replacement succeeds. Audio lesson generation retains streaming progress and
reconnects to its original job after a disconnect. Reopening the app can discover
queued and running lessons through the existing pending-jobs API. A lost network
connection is not a reason to automatically generate the content again.
