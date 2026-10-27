# iOS daily practice widget

The Home Screen widgets show today's spoken and listened words for the current learning language, using the same `WordActivityNotifier.summaryFor` totals as Profile / Daily Goal. Large widgets also show the current learning language, earned practice level and speaking leaderboard rank. The medium widget adds a compact trophy/rank column beside Speaking and Listening. The small widget keeps the two word counts and shows a compact trophy/rank badge beside Today. Large is available on supported iPhones and iPads, wide extra-large on iPad, and extra-large portrait on iOS/iPadOS 27 or newer. The whole widget opens `bantera://ai-chat`; it does not start a call or enable the microphone.

## Data and refresh

- `PracticeWidgetService` sends a dated aggregate snapshot through `bantera/practice_widget`. The shared file contains counts, sign-in state, locale, learning language, earned level, dated leaderboard rank and translated labels only. It contains no account identifiers, tokens, recordings or chat history.
- Both Runner and the existing WidgetKit extension use App Group `group.bantera.lisenhuang.com`. Enable this group on both signing identifiers when setting up another developer machine or distribution profiles.
- The native bridge atomically writes `practice-widget.json` in the shared container, protected until first device unlock, then asks WidgetKit to reload. Identical snapshots are deduplicated. iOS controls actual refresh timing; widgets are not second-by-second live counters.
- Changes to counts, learning language, app language, account and app resume update the snapshot. Sign-out/deletion clears all progress details. Switching the learning language clears the old level; the leaderboard rank spans languages. Writes are serialised so a delayed previous account update cannot win over a clear.
- The level and rank reuse existing Practice and leaderboard responses and account-scoped cached snapshots. Unknown values display a dash; a missing rank does not imply last place. No extra API request is added for the widget.
- A midnight timeline entry resets the displayed counts to zero without requiring the app to run. Date checks use the device's local calendar. Opening the app refreshes the current day's actual totals. The rank expires separately at UTC midnight, matching the leaderboard period; the earned level persists.
- The widget performs no network requests and does not change the app's existing activity sync behaviour.

## Navigation

`SceneDelegate` handles the widget URL for both cold launches and an existing scene. A native pending flag is consumed by Flutter. The request waits for authentication/onboarding and an active `MainScaffold`, selects Chats, then opens/reuses the AI chat route. It does not bypass sign-in or call confirmation.

## Adding the widget

After updating, open Bantera once to populate the shared counts. On the Home Screen, long-press an empty area, choose Edit > Add Widget, search for Bantera, then select Daily practice in an available size. Apps cannot add a Home Screen widget on the user's behalf.

## Verification

- Flutter tests: `flutter test test/core/practice_widget_service_test.dart test/core/word_activity_notifier_test.dart`
- Simulator-only native tests: `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,id=<simulator-id>' -only-testing:RunnerTests/PracticeWidgetTests test`
- Native tests cover date rollover, signed-out counts, strict deep links and legacy snapshot decoding, progress/account isolation, rank expiry and light/dark rendering at supported widget sizes.
- Installation on a physical iPhone is separate from testing. Do not launch or test on the user's phone without permission.

## Widget discovery and guide (current behavior: 3.29.2 / 492)

- `WidgetDiscoveryService` checks `WidgetCenter.shared.getCurrentConfigurations`
  through the existing native bridge on startup, foreground return and guide exit.
  Configured widgets hide the Goal suggestion, but Settings always keeps the
  neutral Add a widget guide on iPhone/iPad. Errors, missing plugins and timeouts
  are unknown, never evidence of absence. The Goal suggestion requires confirmed
  absence. This is configuration discovery, not widget viewing or usage tracking.
- Only iOS/iPadOS enables discovery. Android does not query the channel, store a
  dismissal, or display either entry point.
- Confirmed absence shows a compact Goal suggestion directly after the profile
  header. Settings always shows Add a widget above Display language, regardless
  of detection or dismissal. Not now in Goal opens a confirmation; Cancel leaves
  it visible. Only Don't show again stores
  the local dismissal, which applies exclusively to the Goal card. Detection
  state is deliberately not cached across app launches.
- The dismissal is a small file in Application Support, outside safe-to-clear
  cache categories. No account identifier, backend request or usage record is
  involved. A failed write leaves the suggestion visible and offers a retry.
- Both entry points open `WidgetGuideScreen`. Its localized previews render
  `BanteraPracticeWidgetView`, the actual extension view, using explicit example
  data and the current app locale/theme. The guide supports small, medium and
  large, plus extra-large on iPad. Previews are generated on demand, not downloaded
  or saved. Instructions include Edit → Add Widget and the + alternative on older
  OS versions. The app cannot install a widget for the user.
- Localized guide text and accessible scrolling layouts support all 17 app
  languages. Preview images have descriptive accessibility labels; the instructions
  remain real text and resize with accessibility text settings.

Focused checks:
`flutter test --no-pub test/core/widget_discovery_service_test.dart test/presentation/widgets/widget_discovery_test.dart test/core/practice_widget_service_test.dart`

Native preview checks (simulator only):
`xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,id=<simulator-id>' -only-testing:RunnerTests/WidgetDiscoveryPreviewTests test`

`tool/widget_discovery_preview.dart` is a debug-only simulator QA entry point with
Goal/Settings/Guide navigation, theme switching and 2.5x text scaling. It uses the
real native discovery and preview channel. Never build it for distribution or
install it on a physical device; production builds use `lib/main.dart`.

Verification for 3.29.0 (490), 27 October 2026:
- 82 Flutter tests passed, including discovery errors/timeouts, persistent dismissal,
  both entry points, accessible tap targets/labels/contrast, 2.5x localized layouts,
  regional language ordering and the required callback/CallKit/audio regressions.
- Five native widget tests passed on the iPadOS 26.4.1 simulator, rendering actual
  small/medium/large/extra-large views in light and dark modes.
- iPhone and iPad simulators verified Goal placement, Settings availability after
  confirmed dismissal, guide previews and enlarged text. Adding a widget through
  the iPhone Home Screen gallery hid both suggestions on returning to Bantera.
- No physical-device launch or testing is authorized. iOS 15 compatibility is
  retained by availability guards; runtime checks used iOS/iPadOS 26.4.1.


### Discovery recovery (3.29.1 / 491)

A failed preference read no longer disables discovery for the rest of the app
session. Unknown results retry up to three times while foregrounded. A valid
response arriving after the eight-second timeout is accepted unless a newer
request or foreground session superseded it. Timers stop in the background.
Settings remains accessible during unknown detection; the Goal card still needs
confirmed absence and a successfully read dismissal preference.

Two small, overwritten local files in Application Support record the last
Flutter/native discovery state (`widget-discovery-state.json` and
`widget-discovery-native.json`). They contain state, timestamp, retry count,
preference availability, widget kinds/families/count, and error domain/code only.
They contain no account, chat, location or progress data and are never uploaded.
These distinguish an API timeout/error from an unexpected positive configuration
on a physical device without launching or testing it remotely.

The Settings entry has no dismissal control and does not consult the Goal
dismissal preference. Removing a previously configured widget restores Settings
on the next foreground check, including widgets added before this release.

User-facing language-code labels use conventional casing (`en-NZ`, `zh-CN`,
`mi-NZ`); stored identifiers and API values remain unchanged.

Follow-up verification: 108 focused Flutter tests passed across discovery,
widget layouts, labels, regional ordering and callback/audio regressions. The
new removal regression covers a widget present before initialization and a
previously dismissed Goal suggestion. Physical widget detection still requires
the user to open the installed app before its local diagnostic can be inspected.

### Permanent Settings access (3.29.2 / 492)

The user approved keeping Add a widget permanently available in Settings on
iPhone/iPad. This supersedes the original rule that a positive WidgetKit result
hides both entry points. Settings has no dismissal action and ignores the Goal
dismissal preference. The Goal card still requires confirmed absence; Android
continues to show neither entry. Adding or removing widgets, including widgets
configured before an app update, cannot remove access to the Settings guide.

After the user opened 3.29.1, a read-only inspection of its two local diagnostic
files recorded a successful WidgetKit response with five BanteraPracticeWidget
configurations (two medium, large, small, and extra-large portrait), no error,
and no Goal dismissal. This explains why that version hid both entries. It does
not prove those configurations are currently visible: the user reports no widget.
The public WidgetInfo API provides kind, family and configuration, but no location
or freshness marker to distinguish stale records from widgets placed elsewhere.

A [developer report on Apple's forums](https://developer.apple.com/forums/thread/840478)
describes configurations remaining after widgets are resized and removed. That
is supporting evidence of a possible system issue, not an Apple-confirmed cause
for this device. We do not reinterpret a positive response as absence or filter
valid iOS 27 families.

The focused regressions now cover permanent Settings access across present,
absent, unknown and dismissed states, a positive detection opening the guide
without a dismissal control, and Android visibility remaining off.

Verification for 3.29.2 (492): 52 focused Flutter tests passed, including
permanent Settings access, dismissal, large localized layouts, and the required
callback/CallKit/audio regressions. The physical phone is installation-only.
