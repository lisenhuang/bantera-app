# Practice audio controls

App 3.8.0 (434) adds an outlined speed badge immediately left of Practice's overflow menu. It starts at 1× and cycles through 0.5×, 0.75×, 1×, 1.25× and 1.5× in ascending order, wrapping at the end. The badge has a 48-point tap target and a localized accessibility tooltip. The selected speed is held while the Practice screen remains mounted; it does not change the separate dialogue player's saved preference.

App 3.8.1 (435) fixes the visible badge at 48 × 30 points with fully rounded pill ends. Its frame no longer changes width with the speed label. The outer tap target remains 48 × 48 points.

Q1, both Q2 answers, and recorded-answer playback now pause and resume using the existing audio source. Repeated taps preserve the position, waveform progress, listening-credit ledger and playback event. Switching clips or replaying a completed clip starts that clip from the beginning. Speed changes apply to active or paused audio without replacing its source; new clips receive the selected rate before playback begins. Leaving Practice, recording, and call interruptions retain the existing stop behavior.

The regression test covers all five speeds, Q1/Q2 pause and resume, a rate change while paused and while playing, clip switching, completion replay, and stopping when Practice becomes inactive. The 78-test verification run also includes header/Practice layouts, callback/CallKit, audio routing, call timing and interruptions. Light-theme preview was visually inspected; light and dark golden images were refreshed for the added badge. Analyzer reports no errors or warnings, with existing informational findings remaining.

No backend or website changes are required. Physical locked-screen callback audio is not established by these tests or by installation; it remains a user acceptance check. Device installation does not include launching or testing the physical app.
