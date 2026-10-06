# Bantera AI spoken-word credit

AI voice messages and completed learner speech turns from inline audio calls contribute to the existing Words spoken today / daily goal ledger only after local language verification. Typed messages and AI replies never contribute.

The user's rule is all-or-nothing: if speech mixes the learning language with another language, the entire utterance receives zero credit. Do not count its target-language fragments separately.

Implementation:

- Analyse Gemini's input transcription on the device, never its output transcript or a translation.
- Use Apple's NaturalLanguage on iOS and bundled ML Kit language identification on Android. No additional cloud language-detection request is made.
- Check the whole utterance, punctuation-separated clauses and overlapping three-word windows. Every probe must identify the target language with at least 0.85 confidence. iOS also checks context-aware word-level language tags. A conflicting or uncertain result rejects the entire utterance.
- Very short or oversized inputs are skipped conservatively. Accents share the existing base-language bucket. Mandarin and Cantonese are not conflated: if the recognizer cannot establish Cantonese distinctly, it earns no credit.
- Use the existing subtitle tokenizer for accepted word totals, and the utterance's local creation time for the daily bucket.
- Save a unique speech-event ID alongside the word ledger atomically. Retries and relaunches cannot add the same utterance twice. Clearing AI history leaves earned progress intact. Account checks prevent a delayed result being added to another user.

This is an estimate, not proof that every word belongs to one language. Short loanwords, names, recognition mistakes and language switching can fool text classifiers. The conservative checks can also reject legitimate single-language speech. Do not claim perfect mixed-language detection or accent verification. Speech-to-text output can differ from the audio; no words are credited when reliable input transcription/detection is unavailable.

Tests cover mixed/conflicting/uncertain evidence, complete-message rejection, duplicate events across retries/restart, and account isolation. Native language samples check single-language and mixed-language behaviour. Physical-device voice message/call testing is still needed after installation.

### AI chat audio update (2.0.121 / 309)

Bantera AI is first in Online, using the Bantera logo and the shared chat-card
spacing. The composer accepts recorded voice only; existing transcripts remain
readable. A freshly received voice-message reply requests playback once. Loading
history, translating a transcript and saving live-call turns do not replay audio.

The iOS native bridge waits for a microphone frame before completing call startup.
It rebuilds both audio directions after a stopped engine/configuration change,
re-queues unplayed output and checks capture liveness. Recovery is bounded and
reports failure instead of leaving a silent connected call. Speaker switching and
clearing interrupted playback preserve capture.

The voice-message composer starts at 3:00 and uses elapsed time to auto-send once at 0:00. Cancel and manual send stop the countdown. Backend 1.0.161 is required for messages longer than 60 seconds.


On the user's iPhone 17 Pro, the native audio probe initially reproduced zero
microphone frames from VoiceProcessingIO. A per-call fallback to the system
voice-chat session without that failing engine mode passed capture (131,149
frames), rendered output and route-switch checks. Use the normal `lib/main.dart`
entrypoint for all delivered builds. The temporary automatic probe is not part of
app startup or production UI. The native hardware XCTest is opt-in via
`BANTERA_TEST_AUDIO_HARDWARE=1`; its first run could not bootstrap on the device,
so it is not reported as passing. Flutter tests separately cover one-shot autoplay,
voice-only input, 180-second expiry/cancellation and local history.

### Speaker echo fix (2.0.122 / 310)

The earlier unprocessed fallback restored audio but allowed speaker echo to trigger
Gemini's interruption detection. Voice-chat session mode alone does not enable
acoustic echo cancellation. The bridge now prefers Apple's echo-cancelled input
on supported iOS 18.2+ devices, using the required play-and-record/default session
configuration. It verifies the enabled state after activation and preserves the
preference when switching speaker routes. Other devices use AVAudioEngine voice
processing. Recovery never deliberately disables both echo-cancellation paths.
Microphone forwarding remains active during AI playback; no turn-based mute was
added.

Apple reference: https://developer.apple.com/documentation/avfaudio/avaudiosession/setprefersechocancelledinput(_:)

A native probe on the user's iPhone 17 Pro passed with 132,781 captured frames,
48,000 rendered output frames, microphone capture continuing during output, and
`echoCancellation=true` before and after speaker switching. The engine had zero
recoveries and no conversion errors. This verifies system activation and duplex
audio; a conversational listening test is still needed to assess residual echo in
the user's room. The delivered build uses `lib/main.dart` with no automatic probe.

### Transcription and privacy controls (2.0.123 / 311)

Voice messages and call turns show transcription by default. They no longer
start translation automatically, and cached translations remain hidden until
requested. The top-right translation icon on each iOS message bubble reveals or
requests a local translation; once visible, it requests a fresh translation.
Translation continues to use the on-device translation service.

The privacy banner has a close icon. Its dismissal is saved per account in the
private on-device AI storage, separately from deletable chat history. The menu's
Privacy notice action always allows the disclosure to be read again.

The conversation list anchors at the newest message on its first layout. Opening
a long history no longer animates through earlier messages; newly arriving
messages can still scroll into view during an open conversation.

### DM styling and contrast (2.0.124 / 312)

AI messages follow the human DM surface styling: a 12% primary tint for outgoing
messages, neutral incoming surfaces, outline borders, 18-point corners and
body-large foreground text. Playback has a filled play/pause control and progress
bar; the translation action stays at the top right. The composer supports holding
to record and releasing to send, plus an accessible tap-to-record microphone.
The 180-second recording countdown and nine-minute inline call countdown remain.
Light and dark theme checks assert at least 4.5:1 contrast for transcript text.

Active iOS AI calls keep their duplex audio session and WebSocket when the app
backgrounds or the screen locks. Existing UIBackgroundModes audio and the native
playAndRecord category support this; the screen no longer hangs up or stops the
shared audio session on pause. The elapsed-time countdown and server nine-minute
deadline still run. Voice-message recording is cancelled on backgrounding, and
detaching the app, leaving the chat, or an audio interruption still ends a call.
Widget lifecycle checks verify pause/resume keeps the call active without stopping
playback. A real conversation with the physical iPhone locked remains a user check.
Reference: https://developer.apple.com/documentation/avfaudio/avaudiosession/category-swift.struct/playandrecord

### Streaming voice messages and lock-screen calls (2.0.124 / 312)

A voice message opens `/ws/chat/ai/voice` when recording starts. Mono PCM16 at
16 kHz streams while the 180-second recording countdown runs. Send (or countdown
expiry) sends an explicit commit with a fresh device clock/timezone. Gemini's
manual activity detection prevents a spoken reply before that commit. Cancel
closes the connection without committing. PCM is retained locally for history and
retry; the backend keeps only a bounded in-memory copy for provider recovery.

Reply PCM starts playing as soon as it arrives, using a playback-only native audio
engine, without opening the microphone again. A failed connection before commit
can use the compatible HTTP upload route. After commit, a transport failure marks
the message failed for explicit retry rather than automatically submitting it twice.
A provider quota retry discards partial reply audio before replaying the recording.

Real iOS calls expose a Live Activity with the Bantera logo, remaining time,
mute/unmute, speaker/earpiece, and End controls. Actions use LiveActivityIntent in
the app process, matched to the active call ID. Start/update/end mirror the Flutter
call state; old activities are removed on process restart. The widget extension
contains all 17 app localisations. Activities are optional: disabled system Live
Activities never prevent a call. Real locked-device audio routing and button taps
still require a physical conversation check.

Provider expiry is distinct from quota. A call reconnects only on an explicit
`session_expired` signal, restores recent on-device transcript context, and keeps
its original elapsed-time countdown. Reconnection never grants another nine
minutes. Google documents around ten minutes per connection; each voice message
gets its own connection, so time spent looking at an idle chat does not count.

Validation: 11 Flutter tests (including real localhost WebSocket upload, cancel,
partial-output reset and early playback), clean targeted analysis, signed iOS
release with embedded widget. A synthetic real Gemini streaming test delivered
first audio 2.1 s after commit and completed in 3.6 s on this run; this is not a
latency guarantee for production mobile networks.
