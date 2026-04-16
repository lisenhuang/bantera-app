# Translation: iOS 18 Path vs iOS 26 Path

The app uses two different translation implementations depending on the device's iOS version.

## Apple framework background

- **iOS 18 — Translation framework**: Apple's in-app text translation API for developers. Apple describes it as "Offer in-app translations with the Translation framework." Allows apps to translate text using on-device models via `TranslationSession`.
- **iOS 26 — Live Translation**: Apple's newer real-time translation feature. Developers can integrate it into apps through the Call Translation API, and it powers the broader on-device translation system with explicit language pack management via `LanguageAvailability`.

## Comparison

|                          | iOS 18–25                                | iOS 26+                                      |
|--------------------------|------------------------------------------|----------------------------------------------|
| **Model location**       | On-device                                | On-device                                    |
| **Offline support**      | Yes (after first use)                    | Yes (after language pack download)           |
| **Model download**       | Automatic — system shows a sheet on first use, developer has no control | Explicit — developer uses `LanguageAvailability` to check and trigger downloads |
| **Developer control**    | None — system manages everything         | Full — can check installed packs, pre-download, manage UX |
| **API**                  | `TranslationSession.Configuration` + `.translationTask(configuration:)` | `LanguageAvailability` + `TranslationSession(installedSource:target:)` |

Both paths run on-device and work offline once models are downloaded. The key difference is **who controls the download**: on iOS 18–25 the system does it automatically (and may show an unexpected sheet mid-translation), while on iOS 26 the app manages it explicitly.

## Routing logic

The app always uses the best path available for the device:

- **iOS 26+** → explicit pack management path (`BanteraTranslationService` in `AppDelegate.swift`)
- **iOS 18–25** → automatic system-managed path (`BanteraLegacyTranslationCoordinator.swift`)
- **iOS < 18** → translation not available (button hidden)

## Dev mock override

The Dev screen (16 taps on the Settings title) includes **Mock iOS Version** on all iOS versions. Choices:

- **Real device** — no mock; uses the actual OS for routing.
- **iOS 18.0** — simulates pre–iOS 26 behavior for transcription (no SpeechTranscriber / Live Translation routing) while Dart and native stay aligned.
- **iOS 17.0** — simulates no Translation framework (`supportsBuiltInTranslation` false in Dart; native translation bridge returns empty or unsupported as appropriate).

`SettingsNotifier` persists `devMockIosMajorVersion` (`null`, `17`, or `18`). On startup and when the value changes, Flutter syncs it to native via the `bantera/ios_version` channel; `BanteraIosVersionRouting` reads it from `UserDefaults`.

### Two-layer rule (Dart and Swift)

1. **Product routing** uses **effective** major version: mock if set, otherwise real OS (`ProcessInfo.processInfo.operatingSystemVersion` on Swift, `Platform.operatingSystemVersion` / mock in Dart).
2. **API availability** still requires the **real** device OS: e.g. SpeechTranscriber routing runs only when both effective ≥ 26 and real ≥ 26; Translation.framework handlers require both effective ≥ 18 and real ≥ 18.

So a mock cannot make APIs appear that the device does not support; it can force **legacy** paths on a newer device for testing.
