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

The Dev screen (accessible via 16 taps on the Settings title, iOS 26 devices only) lets you set a mock iOS version. Setting the mock to iOS 18 forces `isLegacyAppleOsPre26 = true` in Dart, which passes `forceCloud: true` to Swift, routing the translation call to `BanteraLegacyTranslationCoordinator` even on a real iOS 26 device. This is useful for testing the iOS 18 path without needing a separate device.

Note: the mock only affects Dart-side feature gates and the `forceCloud` flag. Swift `#available` checks (e.g. for transcription) always evaluate against the real device OS.
