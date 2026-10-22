# iPhone Duo compatibility

Reviewed 22 October 2026 using Apple's [preparation guide](https://developer.apple.com/iphone-duo/prepare/)
and [developer presentation](https://developer.apple.com/videos/play/tech-talks/111461/).

Build with Xcode 27.1 / iOS 27.1 SDK for full-display resizing. Keep the
deployment target at iOS 15.0; the SDK version is not the minimum supported OS.
The app already creates its window from `UIWindowScene` and uses current Flutter
layout constraints rather than cached `UIScreen.main` bounds.

`AppViewport` protects every Flutter route and call overlay from asymmetric
left/right safe-area insets. It updates on window changes without remounting
the navigator. Pages continue to handle their own top/bottom and keyboard
insets. The iPhone orientation declaration now permits both landscape directions
as well as portrait. No device-name or exact-screen-size detection is used.

Bantera uses custom Flutter navigation, so Apple's automatic vertical UIKit tab
bar placement does not apply. It retains its existing bottom navigation within
the safe viewport. This change does not add multiwindow or simultaneous use of
the two displays; the existing single-scene audio/callback engine is preserved.

This is basic resize compatibility, not a fully optimized Duo navigation design.
Reserving the full side inset leaves an empty strip below the system indicators.
Apple recommends standard adaptive bars, or `UIViewReservedRegion` for custom
bars that safely use space outside the rectangular safe area. A future design
should use vertical navigation where appropriate and consider separate listening
and speaking columns on wide windows, rather than simply stretching one column.

The Goal tab ring animates from zero on its first appearance, app resume while
visible, return from a pushed route, and every Goal tab tap (including when
already selected). Ordinary word-count updates animate
from the displayed value. Reduce Motion shows the result immediately, and a
completed goal displays `100%`.

Automated checks cover animation lifecycle, reduced motion, localization,
asymmetric insets, preservation of input across resizing, Practice in narrow
and wide windows, and callback/CallKit/audio regressions. Physical locked-screen
callback audio is not established by these checks.

For a simulator build on Apple Silicon, if Flutter's generic simulator build
misreads Xcode 27.1's combined architecture value, target the installed simulator
explicitly with `xcodebuild`, `ARCHS=arm64`, and `ONLY_ACTIVE_ARCH=YES`. This is a
local build invocation, not a restriction on supported shipping architectures.

Validation on 22 October 2026:

- 124 Flutter tests passed across Goal animation, viewport resizing, Practice,
  widget snapshots/word activity, and callback/CallKit/audio regression suites.
  Analysis of the changed Dart files reported no issues.
- The normal app launched to sign-in on the iOS 27.1 Duo simulator. A local
  Practice preview using the production screen was checked closed, partially
  open, fully open, and in portrait and both landscape orientations. The same
  exercise remained present while resizing; content stayed clear of side UI.
  Authenticated network and microphone flows were not exercised by this preview.
- Small and medium Daily Practice Home Screen widgets rendered without clipping;
  tapping the medium widget opened the signed-out app's sign-in screen. Existing
  widget implementation needed no changes.
- The native widget XCTest attempt was interrupted after the simulator test
  runner stalled during boot. Those native tests did not complete; the widget
  rendering/deep-link checks above were performed directly in the simulator.
- The required unsigned iPhone debug build and signed release build succeeded.
  App and widget both report version 3.4.0 (427), iOS 15.0 minimum, and iOS 27.1
  SDK; deep signature verification passed. The release was installed on the
  user's iPhone without launching it. Physical-device runtime checks, including
  locked-screen callback audio, remain for the user.

The follow-up 3.4.1 (428) change restarts the Goal ring for every Goal tab tap,
including reselection and a tap during an unfinished animation. Its focused
26-test animation/callback/CallKit run passed, and changed-file analysis was clean.
The unsigned debug and signed release builds passed; version 3.4.1 (428) was
installed and confirmed on the user's iPhone without launching it.
