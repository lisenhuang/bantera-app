# Māori language selections

App 2.27.0 (399) and backend 1.26.0 add `mi-NZ`, displayed as
“Māori (New Zealand)”, to both native and learning language selections.
This is a profile/content-language choice, not a new application UI language.

Both pickers merge the product addition into device/API results before applying
the existing regional filters. A missing installed speech pack does not hide the
language. Search accepts Māori, Maori, decomposed macrons, te reo and mi-NZ.
Legacy bare `mi` values normalize to `mi-NZ`; duplicate device variants are merged.

## Speech availability

The current Apple dictation and Gemini speech-generation language lists do not
list Māori. Listing it in a profile must not imply supported speaking Practice.
The app shows a localized unavailable state without polling the generation API.
The backend rejects Māori Practice next/level requests with HTTP 422 and code
`practice_language_unsupported`, before creating progress or queueing preparation.
Existing languages and existing authentication/consent guards are preserved.
Other speech paths retain their existing provider/device capability handling;
this change does not certify Māori recognition, pronunciation or translation.

Sources checked on 20 October 2026:

- https://www.apple.com/nz/ios/feature-availability/
- https://ai.google.dev/gemini-api/docs/speech-generation

## Verification

- 68 app tests passed, including picker/search, unavailable Practice UI, callback,
  CallKit and audio lifecycle regression tests.
- Analysis of changed Dart files passed without findings.
- Backend: 1,008 tests passed, 14 existing optional skips.
- Real Māori speaking/translation and locked-screen callback behavior are not
  verified by these automated checks or by installation.

## Delivery

On 20 October 2026, backend 1.26.0 was deployed as `bantera-20261020-8`.
Signed iOS 2.27.0 (399) was installed and launched on the connected iPhone 17 Pro.
Debug/release iOS builds passed. The release APK was built and verified with the
Bantera release certificate, versionCode 399. No store submission was performed.

## Live capability check, 20 October 2026

Queried the installed app's startup logs on the physical iPhone 17 Pro. Its
`SFSpeechRecognizer` listed 62 locales, and `SpeechTranscriber` listed 45.
Neither included `mi` or `mi-NZ`. Practice's recording bridge uses the former
and rejects locales absent from that list before attempting transcription.
A separate macOS runtime probe returned nil for `SFSpeechRecognizer(mi-NZ)`;
the physical iPhone lists, not that Mac result, establish the device limitation.

An isolated server probe invoked the real `GeneratePracticeAsync` and
`GeneratePracticeAudioAsync` methods with production model/fallback settings,
without publishing material or modifying user profiles. Text model
`chatgpt/gpt-6-luna` produced five A1 drafts. Primary TTS
`gemini-2.5-flash-preview-tts` and fallback `gemini-3.8-flash-lite-tts` produced
three short audio files after regular-key rate-limit failures. No key policy
was changed. The existing Gemini transcription method returned HTTP success but
incorrect words on those synthetic clips:

| Intended text | Recognized text |
| --- | --- |
| Tēnā koe, e hoa! | で な こい えほ あ。 |
| Tēnā koe! | Te naku. |
| Ka kite āpōpō. | Kakai te apoppo. |

This does not validate native pronunciation, text pedagogy or recognition of
human Māori speech. A generated-audio round trip cannot isolate TTS versus STT
errors. It establishes that the current alternative pipeline is not ready to
replace Apple's unavailable Māori recognition. Keep Practice unavailable.

App 2.27.1 (400), prepared locally, additionally excludes Māori from full audio
dialogue generation while retaining profile choices. Backend 1.26.1 rejects it
before generation jobs/provider calls on v1/v2/v3 and admin audio-test routes.
These follow-up changes are not yet deployed or installed. Verification: 38 app
regression tests, clean targeted analysis, iOS debug build, 1,013 backend tests
passed (14 existing optional skips). No physical locked-screen callback test.

## Withdrawn language option

At the user's request, app **2.27.2 (401)** and backend **1.26.2** remove Māori
from native and learning choices. The app filters retired entries even from
cached/device/API lists; the embedded and backend catalogs no longer include it.
Māori naming/search additions were reverted. Previously saved Māori learning
selections show the existing choose-a-language message in Practice without
requesting material. Saved profile records are not silently rewritten. Full
audio generation still rejects retired Māori requests from stale clients.

A separate native-only filter hides `yue-CN` (Cantonese, China mainland) and keeps
`zh-HK` (Hong Kong). Both remain available as learning languages; other languages
and the existing Taiwan visibility rules are preserved.

These changes are prepared locally, not deployed or installed. Verification:
57 app tests passed, targeted analysis clean, and 1,012 backend tests passed with
14 existing optional skips. Callback/CallKit automated regression checks passed;
physical locked-screen callback behavior remains unverified.

## Removal delivered to iPhone

App **2.27.2 (401)** was signed, installed and launched on the physical iPhone
17 Pro on 20 October 2026. The release APK was built and its Bantera certificate
and versionCode 401 verified. No store submission was performed. This supersedes
the earlier “prepared locally” status for the app changes.
