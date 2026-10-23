# Saved practice in the Practice tab: 3.12.0 (442)

Tapping a saved item closes the collection and opens that exercise in the existing
Practice tab. The same cue/reply playback, speed control, pause/resume, recording,
answer feedback, translation and word-explanation controls are used. The server
refreshes signed audio URLs instead of reusing the expiring saved URLs.

Saved review uses the exercise's own language for speech recognition, listening
and speaking activity, word explanations, feedback and text direction. The normal
practice and its answer feedback are retained while reviewing. Next returns to
that practice; the level picker is disabled during saved review. Opening another
saved item keeps the original return destination. Account/language changes clear
the review and pending responses cannot replace the new account's practice.

The original saved ID remains the bookmark/completion identity. Reviews cannot
alter the original score, translation exclusion or attempt count. Repeated reviews
can still record actual listening and speaking activity. Retired material reports
an error rather than silently opening a different exercise.

Requires API 1.39.0. Website unchanged. No store submission or Git push.

The broader practice suite found
an outdated replay Stop expectation from the earlier pause/resume change; its
assertion and dark-mode golden now correctly show Pause. The image difference
was inspected and confined to that icon.

Final UI checks: 45 tests passed after fixing the unsupported-language guard.
The wider 129-test run passed the other 128, including callback/CallKit, audio
routing, call clock and live interruption regressions. Targeted analysis clean.
API 1.39.0 published and verified. Required unsigned iOS debug build passed.

Signed iOS release build and strict code-signature verification passed. Installed
3.12.0 (442) on Ethan's iPhone 17 Pro; the installed-app inventory independently
confirms both version and build. Installation only, no launch or physical-device
testing. Audible playback and locked-screen callback acceptance remain for the
user to check. No Git commit/push or store submission performed.
