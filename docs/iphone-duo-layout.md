# Adaptive layouts for iPhone Duo

This is an app-only change. It does not change API contracts or server data.

## Apple guidance used

- [Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)
- [Prepare your app](https://developer.apple.com/videos/play/tech-talks/111461/)
- [Raise the bar](https://developer.apple.com/videos/play/tech-talks/111462/)
- [Adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Apple engineering guidance for custom frameworks](https://developer.apple.com/forums/thread/847644)

Bantera has Flutter navigation, not a native SwiftUI TabView. Consequently it
must explicitly follow UIKit's window-local verticalBarEdge trait. A wide
window alone never selects a side for the navigation bar. Leading/trailing
system edges are kept physical, including in right-to-left locales.

## Structure

`BanteraAdaptiveViewController` retains the existing Flutter engine. On iOS
27.1 and later it publishes verticalBarEdge, active division/occlusion reserved
regions and UIHingeInteraction posture through `bantera/adaptive_layout`.
Layout and safe-area changes, relevant traits and foreground refreshes update
one Flutter scope. Older systems use the ordinary horizontal navigation.
Ordinary iPhones retain portrait orientation; iPads and windows with native
hinge/vertical-bar signals can rotate.

`AdaptiveColumns` preserves its two elements while repositioning their render
boxes. It uses usable constraints and text scaling; an active vertical division
provides the exact gap. The chat workspace retains its detail Navigator across
resizing. Drafts, selection, scroll controllers and player/recorder ownership
are not rebuilt merely because the arrangement changes. Word explanations and
reminder links use that same navigator. Explicitly leaving Chats still stops
playback as before.

Practice retains the recording layout snapshot around the live microphone,
including the header and both columns. Goal keeps Leaderboard and Daily Goal
together, with achievements/activity alongside. Long dialogues retain their
player and reveal/translation setting, with a transcript alongside when room
permits. The player frame uses an actual horizontal division for tabletop
content/controls separation. AI paragraph width is limited independently of
Markdown tables and existing media cards.

Flutter menus remain anchored to their controls. The main Practice, chat and
player dialogs/sheets choose a clear side of an active division; their maximum
width is bounded. The app keeps its existing keyboard-dismissal behavior,
VoiceOver labels, icon animations and Reduce Motion behavior.

## Simulator fixtures

`tool/duo_layout_preview.dart` is debug-only and uses local sample content, with
the actual Practice, Goal and AI conversation widgets. It is never the release
entry point. Final device builds must use `lib/main.dart`.

Verification results and screenshots are recorded with the delivery notes.
Physical-device callback audio is not proven by simulator or unit tests.

## Verification for 3.30.0 (493)

- 47 focused tests passed: adaptive placement/state/focus, fold and tabletop
  geometry, accessible text sizing, repeated tab taps, microphone hold stability,
  callback, CallKit, audio routing, call clock and live interruption regressions.
- Another 28 focused Practice audio/header/recording and Profile/Settings tests
  passed during implementation.
- iPhone Duo iOS 27.1: inner and outer displays in portrait and landscape,
  partially open/tabletop, and left and right Split View positions were inspected.
  The same selected AI conversation survived folding and resizing.
- Large text (2.5x), light/dark appearance and accessibility-tree visibility of
  both chat panes were inspected. This does not substitute for a complete
  VoiceOver usability review.
- iPhone 17 Pro iOS 26.4.1: narrow layout and portrait restriction verified.
- iPad Pro 13-inch iPadOS 26.4.1: portrait/landscape adaptive layouts verified.
- The new adaptive files pass static analysis. Repository-wide analysis has no
  errors or warnings, but retains existing informational lint findings.
- Production debug and signed release builds use `lib/main.dart`. The preview
  entry point and its sample data are not installed on the physical iPhone.

Screenshots are included in the [visual guide](iphone-duo-visual-guide.md). They use local
fixtures and are layout evidence, not verification of live server conversations.
No physical-device tests or locked-screen callback audio checks were performed.
The newer UIKit APIs are availability-guarded; iOS 15 itself was not exercised
in this simulator matrix. Android keeps the horizontal navigation fallback;
an Android device was not exercised in this pass.

## Chat navigation correction in 3.30.2 (495)

Opening an AI, DM or group conversation hides the main Practice/Chats/Goal
navigation. The conversation uses the reclaimed space, with system safe areas
restored. Returning to the conversation list restores the tabs. This changes
visibility and constraints without replacing the nested navigator or session.
Wide chat layouts retain their conversation list alongside the detail pane.
The 3.30.0 visual guide is a historical layout review; its visible chat tabs
are superseded by this behavior.
