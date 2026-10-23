# Completed voice-reply playback: 3.10.1 (439)

Receiving and playback controls are independent. Once a reply's complete audio is
saved, its button displays Pause while automatic playback continues. The same
button resumes the existing native audio queue from its paused position; it does
not restart the file or download. Other saved messages can be played without
waiting for the current reply operation to end. Selecting one stops automatic
output first so the two players do not compete.

Native playback-only pause/resume uses AVAudioPlayerNode on iOS and AudioTrack on
Android. CallKit and active call audio are guarded. Time spent explicitly paused
does not count toward the playback-drain timeout. Recording a new message and
leaving the conversation still stop playback while preserving received replies.
No backend or website change is required.

## Validation (23 October 2026)

- 34 focused Flutter tests passed, including saved-reply pause/resume, chat
  controls during playback, overlapping replies, navigation, and mandatory
  callback/CallKit, audio route, call clock, and live interruption regressions.
- AI chat analysis and `git diff --check` passed.
- Two native iOS simulator tests passed: pausing/resuming the player without
  restarting, and rejecting playback controls while CallKit owns audio.
- Android native compilation and all four playback-progress unit tests passed.
  An initial concurrent-build attempt lost a generated Flutter intermediate;
  the sequential rerun passed.
- Debug iOS and signed release builds passed. The release signature verified.
- Installed on Ethan's iPhone 17 Pro; device inventory confirms 3.10.1 (439).
  The app was not launched or tested on the physical device. Audible playback
  and locked-screen callback acceptance remain for the user to check.

No commit, push, or store submission was performed for this change.
