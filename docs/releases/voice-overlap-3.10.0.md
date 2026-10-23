# Voice-message continuity: 3.10.0 (438)

A new recording opens its own voice-message stream immediately. Sending commits
that recording without waiting for an earlier reply to finish downloading or
playing. Each request owns its provisional caption, audio, attachments and saved
response. Replies remain next to their originating user message even when they
finish in a different order. Only the newest reply can play automatically.

Leaving or covering the chat stops playback and cancels an unsubmitted recording,
but committed replies continue receiving through a retained account-scoped
controller. Reopening while receiving uses that same conversation. Previously
interrupted playback does not restart automatically. Clear-history, account and
consent invalidation still close streams. This covers navigation within a running
app, not guaranteed execution after force quit or operating-system suspension.

The app opts into backend 1.37.0's bounded voice-message overlap. Up to three voice
message sessions may coexist; phone calls and legacy clients retain exclusive
admission. No database migration, new secret or website change is required.

Validation: 74 focused app tests passed across overlap, leave/reopen, both response
completion orders, cancellation, silence, streaming, image input, chat, history,
Markdown, callback/CallKit and audio regressions. Changed AI directories analyzed
without issues. iOS debug and signed release builds passed; signature verified.
3.10.0 (438) was installed without launching/testing the physical iPhone.

Q2 audit: each newly assigned exercise already chooses Swap using
Random.Shared.Next(2), so either answer position has a 50% probability. Presentation
and scoring use the same stored value; Flutter preserves the server order.
A read-only aggregate on 23 October 2026 counted 360 saved exposures: correct first
192 (53.3%), correct second 168 (46.7%). This does not indicate a position bias.
Unfinished exercises deliberately retain their existing order. No shuffle change.
