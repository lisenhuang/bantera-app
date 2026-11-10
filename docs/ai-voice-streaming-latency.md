# AI voice playback latency

App 3.38.4 (524), 10 November 2026. Works with the deployed backend 1.56.4.

## Diagnosis

The app streams microphone PCM over WSS. The vocabulary notebook is not included
in its automatic device snapshot. V4 prompts do not mandate reading vocabulary
on every ordinary turn. However, the app initialized both V3 and V4 reply guards
as held. An ordinary reply without a qualifying device tool stayed buffered until
`complete` (voice messages) or `turnComplete` (live calls).

The owner's post-deployment server sample at 21:36:50 NZ time measured 3,205 ms
from commit to first outbound audio and 6,929 ms from commit to completion. The
old app could therefore add about 3.7 seconds of output buffering. Those are
server measurements, not measured physical-phone playback timings. The single
tool round took 4 ms to execute; that does not include the model's time to choose
the tool, and tool identity was not recorded.

## Change and safety boundary

- Negotiated V4 ordinary audio and captions stream immediately. V3 keeps its
  legacy initial guard for compatibility.
- Actual review operations activate the guard before local state changes. Their
  device-authored speech is still validated before playback and acknowledgment.
- A review mutation arriving after ordinary audio or model text has already
  streamed is rejected with `review_requires_new_turn` before changing progress.
  The model is told not to retry that action in this turn and to ask the learner
  to continue next turn. Output cannot be retroactively validated or replayed.
- Notebook reads/writes remain available during ordinary conversation. Pausing
  an unfinished review happens at completion, outside first-audio playback.
- Retry resets, new call turns and interruptions preserve the negotiated policy
  but reset turn-local output/review state. Callback startup/auth/audio routing,
  recording, transcript refinement and saved history are unchanged.

## Remaining latency and research

Provider setup/generation and transcript refinement still take time. The app also
awaits a device snapshot before opening WSS: saved-media refresh and activity sync
have bounded network reads. That may delay connection and buffer short input,
but the current server measurements cannot quantify time before connection.
This release removes the confirmed output gate; it does not claim zero latency
or remove existing context features without a separately verified replacement.

Google recommends small incremental chunks without significant client buffering:
[Live best practices](https://ai.google.dev/gemini-api/docs/live-api/best-practices).
[Live tools](https://ai.google.dev/gemini-api/docs/live-api/tools) describes
synchronous tool behavior for Gemini 3.1 Flash Live. Transcription can arrive
independently of generated content, so the fix does not infer quiz intent from
whether a transcript arrived first:
[Live reference](https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/models/live-api).

## Verification

Real WebSocket tests deliberately withhold completion and use an event-queue
barrier to verify first audio/captions, legacy behavior, invalid review output,
reset recovery and late tool rejection without progress changes or duplicate
playback. Live-controller tests cover subsequent turns and interruption.
Required regression/build/install results are recorded at delivery.

App-only fix: no backend migration, configuration or deployment required. Existing
backend diagnostics remain enabled. Installation does not launch the physical
phone app or establish real-world callback/latency behavior.

Final verification: **306 AI/CallKit tests passed**, including eight new socket
and live-controller latency tests; focused analysis reported no issues. Full
analysis had only existing informational lints. Required debug and signed release
iOS builds passed, and deep/strict code signature validation passed.

Installed **3.38.4 (524)** on Ethan's connected iPhone and verified the installed
version through device inventory. The app was not launched or tested on the
physical phone. No backend deployment, Git commit/push or store submission.
