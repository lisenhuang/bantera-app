# Practice transcription and language flags: 3.14.2 (448)

The sentence duplication reported again after the second attempt shows that the
3.14.0/3.14.1 partial-hypothesis merger was unreliable. That merger is removed.
For Practice and other callers requesting transcription without auto-correction,
iOS 26+ now uses SpeechTranscriber when the hardware and requested locale are
supported. It reads the whole saved audio file, including silence, and consumes
only finalized passages. Tentative revisions are never appended, confidence
attributes are retained, and each attempt creates a new collector. Genuine
repetitions in distinct finalized passages remain. An analyzer error fails the
attempt rather than grading an incomplete transcript. No expected-answer text is
provided to the recognizer.

Other devices/locales retain the legacy recognizer and its previous final-only
result behavior. This removes the introduced duplication risk there, but does
not promise to repair Apple's legacy pause-related loss of earlier speech.
Chat transcription keeps its existing engine and correction policy. No recording
button or CallKit audio-session behavior changed. Modern on-device assets may be
downloaded if not already installed; no cloud transcription fallback is added.

The shared audio-file helper now retains converted temporary files until
transcription finishes, rather than deleting them at the end of an inner scope.

Translation-language rows have decorative country flags for regional locales and
clearly associated languages (for example Japanese). Broad language labels such
as English, Arabic and Chinese use a globe, so they do not imply a particular
country. Selection, download indicators and saved preferences are unchanged.

Validation: 52 focused Flutter tests passed across the regression group and the
corrected flag/layout tests. Callback/CallKit, audio routing, call clock and Live
interruption checks passed. Focused analysis clean. Four native regression tests
passed on the iOS 26.2 simulator: finalized speech across a silent pause, revised
Chinese hypotheses, genuine repetitions/new-attempt isolation, and OS framework
guards. The iOS 26.5 test destination stalled before executing tests; the existing
built test bundle then passed on an already booted 26.2 simulator. These tests
exercise result assembly and compatibility guards, not microphone recognition.
Unsigned iOS debug and signed release builds passed. Strict signature verification
passed. Installed on Ethan’s iPhone 17 Pro without launching it; device inventory
confirmed version 3.14.2 (448).
Physical microphone recognition and locked-screen CallKit audio remain untested;
installation does not verify them and those acceptance checks remain with the user. No server deployment,
store submission, commit or push is part of this change.
