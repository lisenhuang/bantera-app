# AI voice-message reply status

App 3.38.2 (522) replaces the old audio-sending indicator, which remained visible
until a response bubble was received, with one localized progress row.

Observable phases:

- Sending audio: preparing the recording/connection and queuing the final commit.
- Waiting for AI: the completed recording has been handed to the WebSocket;
  this includes network transit and response preparation, not a claim about
  the provider's internal reasoning or an acknowledged server upload receipt.
- Checking your vocabulary: an actual notebook tool operation is pending.
  Conversation-mode/pause/cancel bookkeeping does not announce a vocabulary check.
- Searching the web / finding pictures / finding videos: the corresponding
  device tool is pending, including downloads; finally returns to the current
  response phase on either success or failure.
- Bantera AI is replying: response audio is arriving. Review audio may still be
  buffered for validation before it becomes audible.

Each pending message owns its activity, and each asynchronous tool has a distinct
token so a late completion cannot erase a newer tool's status. The newest pending
reply drives the single row. The composer retains its normal recording label;
it no longer repeats the same progress sentence. Completion/cancellation removes
finished jobs from status selection. Retry resets the base waiting phase.

No backend or website changes, additional AI requests, persisted activity data,
or protocol changes. Text uses the app's 17 localizations, a live-region semantic
announcement and wrapping at large accessibility text sizes.

Verification: 64 focused tests passed, covering socket handoff/reset/output,
asynchronous tool completion, separate overlapping replies, all localized phases
in narrow large-text layouts, review/photo search and required callback/CallKit/
audio regressions. Actual provider internal reasoning is not exposed by the API.

Final static analysis passed its errors/warnings gate. Required debug and signed
iOS builds passed; app signature verified. Installed 3.38.2 (522) and confirmed
its version through iPhone app inventory without launch or physical-phone tests.
No backend deployment was needed. The preceding app/backend fixes were pushed to
main before this work and their exact-commit CI runs passed. This status update
remains uncommitted and unpushed.
