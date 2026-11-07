# Device-managed vocabulary review, protocol V3

## Diagnosis

The previous `quiz` implementation persisted selected IDs in `quizProgress`, so merely selecting a word consumed it for that round. An omitted `selection` reverted to the most recent 20 entries. These exclusions were not completed reviews, and model history/resumption was not a durable source of scope or current-item identity. Prompt requirements alone did not gate emitted questions.

## Device state and transitions

`AiVocabularyReview` stores `reviewSession` alongside `items` in the account-specific `.vocabulary-v1.json` file. All operations use the existing account queue, active-account checks, temporary-file write and atomic rename. No server database or vocabulary upload is introduced. Only requested tool results leave the device, as before.

A session records a UUID, scope, language, question style, due cutoff, a snapshot of eligible exact IDs, completed/skipped/removed IDs and current question identity/revision. V3 ignores legacy selection exclusions rather than misinterpreting them as completed practice. Existing word records and scheduling remain intact.

- `review_start` creates a session. Repeated starts resume it; changes need `explicitChange` plus the existing session ID.
- `review_next` selects or re-delivers an unfinished item. Selection and listing never update scheduling.
- The app acknowledges question delivery only after a successful message save. A question interrupted before completion remains selected.
- `review_answer` records actual input captured by the transport, not an answer supplied in model arguments. Commands such as next/continue/status do not implicitly count as attempts.
- `review_feedback` needs the exact current item/question and a saved attempt. The same Live model judges equivalent meanings with an accepted/corrective verdict; the device authors the resulting feedback from the saved expression and meaning.
- Only the app's compare-and-commit delivery acknowledgement advances scheduling. It checks the pending token, turn, question ID and content revision. Duplicate acknowledgements have no effect. The existing 1/3/7/14/30-day schedule and one-minute repeated-review handling remain.
- `review_skip` records a skip, not a review. `review_repeat` requires an explicit repeat and an existing session item. `review_pause` preserves the session for unrelated conversation; `review_cancel` explicitly ends it.
- Deleted entries cannot receive feedback. Edited entries require a fresh question delivery. Clearing vocabulary also removes its review state. Signing out prevents pending writes to the previous account.

The due cutoff is the UTC instant the session was created. The pool is frozen then; newly due/added items require a deliberately started new session. Empty notebook, no due items, no language matches, completed, unfinished/skipped, cancelled and storage errors are distinct. Completion is announced after progress is durably acknowledged, not after selection. Removed or skipped items do not produce an all-reviewed claim.

## Output enforcement and limitations

A V3 `ready` handshake enables `AiReviewTurn` for voice messages and real-time calls. Each model turn begins without output permission. `review_conversation` grants ordinary streaming when the review is cancelled/absent/paused. Review actions authorize only device-authored text based on valid saved IDs. Rich-text and emoji tools cannot bypass an unresolved/review output gate.

Questions use either the saved meaning (guess expression) or saved expression (explain meaning), preserving whole phrases. The expression is redacted if it appears literally in its clue. Answer references are not returned before an actual answer is registered. Device-generated questions, feedback and status text are currently English; the saved expression/meaning retain their original languages.

During a review turn, audio and model captions are buffered. At completion the device validates the current revision/token and displays the canonical text. It releases audio only if the model's final output transcript matches that text after case/punctuation normalization. A mismatch becomes a text-only response; it is not silently played or saved as misleading audio. Interrupted buffered output is discarded and does not consume the item.

Limits to the guarantee:

- Natural-language intent/scope/style recognition and semantic answer grading still depend on the same Live model. In particular, the app cannot independently prove that a model request to pause/classify a turn as ordinary conversation matches the learner's spoken intent. Once review mode is selected, target identity and rendered review text are device-enforced.
- The audio check compares the provider's output transcript, not an independent transcription of its audio. It is not an acoustic proof. Review audio has additional turn-completion latency; mismatches and missing authorisation produce a safe text fallback. No second AI service is used.
- Delivery means accepted and saved in the chat, not proof that the learner heard/read it. Scheduling still requires a subsequent actual input and saved feedback.
- Persisted state is device/account local; it does not synchronise to another device. Chat clearing does not erase the independent notebook/session. Vocabulary clearing does.
- Real provider intent/recognition quality and locked-screen device audio require release acceptance testing. Automated socket tests are not physical-device verification.

## Compatibility and production

App 3.38.0 (520) advertises `vocabularyVersion: 3`; backend 1.56.0 negotiates it and adds a version to ready messages. V1/V2 tool actions/prompts remain available unchanged. Version participates in the existing Live resumption identity, preventing reuse of older tool declarations. A new app on an old backend uses legacy behaviour; V3 enforcement must not be claimed there.

No database migrations, new secrets, configuration keys or server-side vocabulary storage. Deploy the compatible backend before releasing the updated app. Old published apps continue to use V1/V2. Production smoke checks: ordinary greeting, due review, two separate voice-message answers, an interrupted/reconnected call, empty/no-due results, mismatched audio fallback, and cancellation. After separate authorization on 7 November 2026, backend 1.56.0 was deployed as `bantera-20261107-1` and app 3.38.0 (520) was installed on the connected iPhone without launch or testing. Public backend/website checks passed. No store submission was performed.

## Practice translation follow-up

All ordinary Practice exercises start with translations hidden, including A0 and exercises with `translationUsed=true`. Restored caches/levels/saved exercises do not restore visibility. Backgrounding hides it again. A0 taps bypass the scoring-warning confirmation; higher levels keep the warning. The server's prior translation-used scoring record is preserved. The earlier explicit Māori server-English exception remains unchanged. System language/download consent, when actually required by the platform, is not bypassed.
