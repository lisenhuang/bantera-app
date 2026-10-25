# Practice pronunciation and mic gestures: 3.16.0 (452)

Optional Pronunciation toggle for Mandarin, Cantonese, Japanese, Korean, Thai,
Hindi, Arabic, Hebrew, Russian, Ukrainian and Greek. Saved per account and
learning locale, initially off. Readings appear above the corresponding source
characters or word groups. Original word selection, the second-tap AI dialog,
audio, translations and answer scoring remain unchanged.

The API returns exact-source-aligned segments with each practice. Older
practices are generated on demand after the user enables Pronunciation. The
request wakes a database-backed worker; there is no automatic bulk backfill. When enabled,
the active screen polls the owned pronunciation endpoint every five seconds
until ready. Switching account or exercise discards late responses. Leaving
Practice or disabling the toggle cancels polling. Errors retain the original
text and offer retry. Settings-save failures are reported instead of silently
forgetting the user's choice.

API 1.40.1 is required for generated readings. Earlier APIs leave the original
practice usable and show the pronunciation unavailable state. No native APIs
or minimum OS requirements changed.

The control sits immediately to the right of Level, with matching rounded styling,
a selected purple tint and a checkmark. Its width stays stable when toggled; the
controls wrap on narrow screens or with larger accessibility text. This follows
optional in-lesson pronunciation support documented by
[Duolingo](https://blog.duolingo.com/japanese-writing-systems/) and
[LingoDeer](https://support.lingodeer.com/en/support/solutions/articles/61000307411-romanization-and-other-reading-pronunciation-aids).

Practice recording now matches the chat gestures: tap to begin, tap again to
check; or hold for 300 ms, speak, and release to check. The circular mic,
pulse and 30-second maximum remain. The localized hint changes to "Release to
check" during a hold and "Tap to check" during tap recording. Pointer cancellation
discards a held recording. Releasing during permission/startup invalidates the
request, including after native recorder startup. Leaving Practice, an incoming
call or a lifecycle interruption invalidates pending recording intents. These
changes do not alter the shared transcription pipeline or the CallKit lifecycle.

Validation: 171 Practice, chat-composer, audio, callback/CallKit, call-clock and
Live interruption tests passed. After analyzer cleanup, the 27 mic and mandatory
callback/CallKit tests passed again. Analysis has no errors or warnings and the
existing 44 informational notices. The pronunciation tests cover all 11 languages,
large text, RTL, two-tap word selection, late responses, persistence, inactive/off
states, stable toggle size and wrapping. Mic tests cover both gestures, repeated
taps, permission/startup release, cancellation, interruption, timeout and
screen-reader activation. Light/dark layout goldens were reviewed and updated.

The website FAQ documents this feature as requiring app 3.15.0 or later. No
App Store submission, Android distribution or Git commit/push is part of this
request.

Release verification: unsigned debug and signed release iOS builds passed;
deep strict code-signature verification passed. Installed 3.16.0 (452) on
Ethan's iPhone 17 Pro and independently verified both version fields through
device inventory. The app was not launched or tested on the physical phone.
Real microphone audio and locked-screen CallKit acceptance checks remain with
the user. Backend 1.40.1 and website 0.19.0 are publicly verified after deployment.
