# Practice corrections: 3.14.1 (447)

Superseded for transcription: the user reported the same duplication after a
second recording. The hypothesis merger below was not a sufficient fix. See
[3.14.2](practice-fixes-3.14.2.md) for its removal and replacement.

The final speech callback can retime an already recognized sentence. The previous
pause accumulator treated a shorter result as a new utterance even when its words
were unchanged, duplicating the whole sentence. Overlapping identical/extended
hypotheses now replace the current snapshot; genuine repetitions with distinct
later audio ranges still append. Existing silent-gap preservation remains in
place. Five native simulator tests cover the reported Chinese sentence, retimed
extensions, actual repeated speech, earlier utterances after silence, and revised
cumulative results. No recording stop/pause-button behavior is changed.

Practice's menu item is now Translation language (localized into all 17 app UI
languages). Its action remains attached while the menu covers Practice. The
handler waits for the menu to return control before checking foreground/route
safety, so the picker actually opens. A widget regression reproduces that route
coverage and verifies supported-language selection UI and safe cancellation.

Explicit choices remain per account and learning language on the device and take
priority over the native language. Without an explicit choice, native translation
is used when available; unsupported pairs use the existing remembered fallback
or ask for a supported language when Show translation is requested. Picking a
language alone does not reveal a translation or alter scoring.

Validation: 43 focused Flutter tests, including callback/CallKit checks, and five
native iOS simulator regression tests passed. Focused analysis clean. Unsigned iOS debug and signed release builds passed;
strict signature verification passed. Installed on Ethan’s iPhone 17 Pro without
launching. Device inventory confirmed version 3.14.1 (447).
No backend/website deployment or store submission is needed. Physical-device
speech behavior remains for the user to check; installation does not test it.
