# Vocabulary quiz progression: 3.14.3 (449)

The vocabulary quiz previously sampled randomly on every tool call. It relied
on the model supplying `excludeIds` (at most 20 IDs) to avoid asking the same word
again. Separate voice-message sessions could forget those exclusions.

The app now saves selected word IDs in the account's existing local vocabulary
file, scoped to the chat conversation. Voice messages, retries, live calls and
CallKit callbacks use the same progress. Selection is serialized with vocabulary
writes, so simultaneous requests cannot draw the same word. Changing the quiz
pool does not forget previously selected words. Selecting a question does not
mark the word reviewed or change its spaced-repetition schedule.

An empty selection returns no word, with an instruction to explain completion
and offer another pool instead of repeating or inventing a question. An explicit
request to revisit a particular word can still use the existing `list` lookup.
Progress resets for a new conversation or after 24 hours without a quiz request;
it survives app restarts. Only IDs still in the notebook are retained.

This is an app-only change using the existing backend tool contract. It cannot
guarantee model obedience if the model skips the vocabulary tool; the backend's
existing instructions already require it for vocabulary quizzes.

Regression coverage includes 30 consecutive questions across repository
instances, simultaneous selections, pool changes, exhaustion, inactivity,
account/conversation isolation, explicit exclusions and controller transport
coverage for voice messages, retries and calls. Callback, CallKit, audio-route,
call-clock and live-interruption regression suites must also pass. Locked-screen
callback audio and live model behavior remain physical-device acceptance checks
for the user; installation alone does not verify them.

Verification on 2026-10-25: all 60 targeted regression tests passed. Flutter
analysis passed with 44 existing informational findings and no errors or warnings.
Both the unsigned debug and signed release iOS builds passed; the release app
passed deep, strict code-signature verification. Build 449 was installed on the
user's iPhone without launching it. No backend or website deployment is needed.
