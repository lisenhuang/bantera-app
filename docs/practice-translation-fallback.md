# Practice translation fallback

Version 3.6.0 (430), 22 October 2026.

Practice prefers the profile's native language. If the device does not support
that source/target pair, it checks the locally remembered fallback for this
account and learning language, then offers only targets supported by the device.
The fallback lives in `practice_translation_languages.json`; it does not change
the profile's native language or global listening-practice translation setting.
A supported native language takes priority over the remembered fallback. If the
source has no supported targets, show an unavailable message and a retry action.
Cantonese remains distinct from Mandarin; Simplified and Traditional Chinese are
matched separately. Same-language text can be displayed without downloading.

On iOS 18+, `LanguageAvailability.supportedLanguages` and `status(from:to:)`
replace the fixed pair picker list. Missing model assets show an app explanation,
then a SwiftUI translation session calls `prepareTranslation()` to let the system
request download permission. Preparation is no longer a native no-op. The native
host finishes dismissing before completing the bridge request. Unsupported-pair
errors and cancellation are no longer all treated as missing models, so cancelling
does not immediately reopen the system sheet. iOS 15–17 keep translation hidden.
Android checks source support and both source/target model installation, then uses
its existing ML Kit download path after the same app confirmation.

References: [Apple language availability](https://developer.apple.com/documentation/translation/languageavailability)
and [preparing downloads](https://developer.apple.com/documentation/translation/translationsession/preparetranslation()).

The existing scoring confirmation stays in place before revealing translations.
No inline scoring explanation was restored. Copy is localized in all 17 locales.
The fallback selector scrolls with large text and the keyboard on compact, wide
and Duo-sized layouts. Cancelled selections/downloads offer an explicit retry.
Account/language changes invalidate pending results; background/call state is
checked before new selection, preparation and translation work.

Validation: 101 focused Flutter tests passed across the final runs, including
fallback persistence, native priority, account/language isolation, cancellation,
old-OS gates, Practice layout/scoring, and callback/CallKit/audio regressions.
Changed-code analysis, unsigned iOS debug build, signed iOS release build, Android
Kotlin compilation and deep signing verification passed. App and widget are both
3.6.0 (430), retain iOS 15.0 minimum and use the iOS 27.1 SDK. No backend update,
migration or new configuration is required. Actual Apple language availability,
model download prompts and locked-screen call audio were not tested on the user's
physical iPhone; installation alone does not establish those runtime behaviors.
