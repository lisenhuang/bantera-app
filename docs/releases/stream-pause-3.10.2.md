# Pause while a voice reply is still arriving: 3.10.2 (440)

The previous fix enabled playback controls only after the server's `complete`
frame and saving the full audio file. That still left the control disabled during
streaming, even though the native player was already speaking. The reported
symptom alone does not establish when the user's full audio reached the phone.

Playback controls now follow the active native player from its first audio
buffer. Pause and Resume work on the provisional response before it has a saved
audio file. Audio and captions continue arriving while paused, the final reply
is saved, and the paused state survives completion. New buffers do not resume
the native player. Receiving indicators remain independent of playback controls.
Server resets reapply a user's paused state after clearing the old audio queue.

This change needs no backend or website release. Existing CallKit ownership,
recording and navigation guards remain in place.

## Validation

- Regression tests reproduced the prior failure before the implementation fix.
- 34 focused Flutter tests passed, including pause before the server completes,
  receiving and saving additional audio while paused, usable streaming controls
  in the iOS chat UI, overlapping replies, navigation and mandatory callback,
  CallKit, audio route, call clock and live interruption checks.
- The shared audio header layout test passed; targeted analysis and diff checks
  passed. Debug iOS build passed.
- Two native iOS simulator tests passed, including feeding another buffer while
  paused without restarting playback, plus rejecting controls under CallKit
  ownership. Signed release build and signature verification passed.
- Installed on Ethan's iPhone 17 Pro; device inventory confirms 3.10.2 (440).
  Installation only, no launch or testing on the physical device. Audible
  playback and locked-screen callback acceptance remain for the user to check.

No commit, push, deployment or store submission was performed for this change.
