# iOS daily practice widget

The small and medium Home Screen widgets show today's spoken and listened words for the current learning language, using the same `WordActivityNotifier.summaryFor` totals as Profile / Daily Goal. The whole widget opens `bantera://ai-chat`; it does not start a call or enable the microphone.

## Data and refresh

- `PracticeWidgetService` sends a dated aggregate snapshot through `bantera/practice_widget`. The shared file contains counts, sign-in state, locale and translated labels only. It contains no account identifiers, tokens, recordings or chat history.
- Both Runner and the existing WidgetKit extension use App Group `group.bantera.lisenhuang.com`. Enable this group on both signing identifiers when setting up another developer machine or distribution profiles.
- The native bridge atomically writes `practice-widget.json` in the shared container, protected until first device unlock, then asks WidgetKit to reload. Identical snapshots are deduplicated. iOS controls actual refresh timing; widgets are not second-by-second live counters.
- Changes to counts, learning language, app language, account and app resume update the snapshot. Sign-out/deletion clears the counts. Writes are serialised so a delayed previous account update cannot win over a clear.
- A midnight timeline entry resets the displayed counts to zero without requiring the app to run. Date checks use the device's local calendar. Opening the app refreshes the current day's actual totals.
- The widget performs no network requests and does not change the app's existing activity sync behaviour.

## Navigation

`SceneDelegate` handles the widget URL for both cold launches and an existing scene. A native pending flag is consumed by Flutter. The request waits for authentication/onboarding and an active `MainScaffold`, selects Chats, then opens/reuses the AI chat route. It does not bypass sign-in or call confirmation.

## Adding the widget

After updating, open Bantera once to populate the shared counts. On the Home Screen, long-press an empty area, choose Edit > Add Widget, search for Bantera, then select Daily practice in the small or medium size. Apps cannot add a Home Screen widget on the user's behalf.

## Verification

- Flutter tests: `flutter test test/core/practice_widget_service_test.dart test/core/word_activity_notifier_test.dart`
- Simulator-only native tests: `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,id=<simulator-id>' -only-testing:RunnerTests/PracticeWidgetTests test`
- Native tests cover date rollover, signed-out counts, strict deep links and light/dark rendering at both widget sizes.
- Installation on a physical iPhone is separate from testing. Do not launch or test on the user's phone without permission.
