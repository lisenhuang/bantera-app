# Device vocabulary tools, 19 October 2026

App 2.19.0 (370) advertises `deviceVocabulary: true, vocabularyVersion: 2`.
Backend 1.21.0 adds three actions to the existing `manage_vocabulary` tool:

- `stats`: full notebook total, filtered count, counts by saved language, unreviewed
  count, and due count. It returns no word definitions or full notebook contents.
- `latest`: the latest saved matching word with meaning, example and timestamps.
- `quiz`: one word selected randomly on the device. `selection` is `recent`
  (newest 20, default), `new` (never reviewed), `due`, or `all`. `excludeIds`
  skips up to 20 words already practised in the conversation.

Existing list/search, add, edit, remove and review actions remain available. Quiz
selection is read-only and does not increment reviews or move the due date. Empty
pools return null instead of inventing words. Random selection can include words
beyond the first listing page. Language/query filters apply before selection.

The model is instructed to call the tool for current notebook questions, use
returned counts rather than conversation memory, and quiz one word at a time
without revealing the answer before the learner tries. Only actual practice may
be marked reviewed. The vocabulary file remains account-isolated on the device;
requested tool results are relayed to the AI for the reply, without a server-side
notebook or database change.

Voice-message retries previously used an HTTP upload path with no device tools.
Retries now use the same WebSocket tool transport as initial recordings. Failed
connections never silently downgrade to a response without vocabulary access.
Already committed streams are still not automatically resubmitted.

Backend capability negotiation preserves the old tool action set for published
apps. Capability version is part of the session-resumption identity, ensuring a
new app does not resume a session with the older tool definitions.

Validation: 42 focused Flutter tests passed, covering data selection and device
execution through voice messages, retries and live calls, plus stream/consent
regressions. 108 backend tests passed; 3 optional provider/database tests skipped.
These tests use synthetic data and mocked provider transport. Model compliance
in a real conversation is not guaranteed by unit tests.

Release verification: unsigned debug and signed release iOS builds passed, as
did strict code-signature verification and targeted Dart analysis. Backend
1.21.0 was deployed as `bantera-20261019-1`. CoreDevice confirmed version 2.19.0,
build 370 installed on the user's iPhone 17 Pro and successfully launched it at
the user's request. No physical-device conversation test was performed.
