# Ordinary conversation and vocabulary review isolation

App 3.38.3 (523), backend 1.56.3. Delivered 8 November 2026.

## Confirmed failure

A model lookup using `review_status` incorrectly set the turn's review flag,
revoked ordinary-conversation authorization, and prevented the completion
fallback. With no delivery text, the app discarded valid reply audio/text and
substituted “The vocabulary review could not continue. Please try again.”
The same status path could unpause and rewrite an existing session. Tests had
covered ordinary no-tool replies and photo search, but not status interleaved
with saving or explaining a word.

## State boundary

- Status is a read-only snapshot, including a successful inactive result when
  no session exists. It never starts, resumes, writes, delivers or acknowledges.
- Definitions, translations, examples and notebook reads/writes are ordinary
  conversation. An unfinished saved session does not lock future chat replies.
- An actual review operation activates the review guard for that turn. Later
  status/notebook/presentation tools cannot discard its validation state.
- An ordinary topic automatically pauses saved review progress without consuming
  entries. An already-issued token stays valid for its original overlapping
  response. Status never exposes that token to another turn.
- Explicit pause/cancel and a superseding review delivery still invalidate the
  older token. Valid feedback is acknowledged at most once after delivery.
- Notebook storage errors are returned as tool errors rather than rewriting an
  unrelated chat as a failed review. Actual review storage failures stay guarded.
- Voice messages, text explanations and live calls share this policy. Pure
  ordinary presentation/search batches release held output before asynchronous
  work; vocabulary batches resolve their mode in tool order. Search stays local.

## Backend compatibility

The app advertises vocabulary protocol 4 and accepts negotiated versions 3/4.
Backend V4 removes mandatory per-turn review bookkeeping and distinguishes
word explanations/saving from quizzes. V1–V3 setup prompts and tool schemas are
unchanged. The V4 schema uses the existing review actions and payloads. Session
context version 15 prevents old instructions being resumed. No database schema,
user-data migration, new environment variables or secrets are required.

Saved vocabulary, summaries, audio and review progress are not reset. Old error
messages remain in history; existing conversations do not need to be cleared.

## Verification

- 298 app AI tests passed, including callbacks, CallKit, audio routing, call
  clocks, interruption, voice overlap, search, UI and vocabulary suites.
- 18 new socket/live-controller tests reproduce antidote definition → examples
  and save → Chinese meaning → greeting, with V3/V4, fresh/active/paused sessions,
  status before/after add, exact audio/captions, presentation tools and invalid
  review operations.
- 45 review-state tests cover read-only snapshots, state/order matrices, storage
  failures, cancellation, valid/invalid delivery, overlapping replies and progress.
- 585 backend AI tests passed; 19 existing opt-in integration/live tests skipped.
- Analysis passes its error/warning gate; 84 existing informational lints remain.
- Debug iOS build and signed release build passed; deep/strict signature validation
  confirms the 3.38.3 (523) Runner app.
- A stale screen test was updated for the single phase label and the existing
  second Clear chat confirmation. It now also detects duplicate status labels.

These tests exercise real app socket handling with deterministic model frames;
they do not claim every possible model tool choice is predictable. Ordinary
no-tool replies still buffer until completion. No physical-phone testing is
included in installation authorization.

## Delivery

Backend 1.56.3 is live as `bantera-20261108-2`; candidate/public checks and all
128 availability probes passed. App 3.38.3 (523) was then installed and confirmed
in the connected iPhone inventory. The app was not launched or tested on the
physical phone. No commit, push or store submission was performed.

### 10 November playback follow-up

The completion-only buffering limitation above is addressed in app 3.38.4 (524).
V4 ordinary replies stream immediately; actual review deliveries remain guarded.
See [voice streaming latency](ai-voice-streaming-latency.md) for the measured delay,
late-tool safety boundary, tests and remaining startup/model latency.
