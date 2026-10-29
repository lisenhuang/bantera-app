import 'dart:async';

import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/chats_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

class _MenuHarness {
  _MenuHarness({bool enabled = true}) : enabled = ValueNotifier(enabled);

  final ValueNotifier<bool> enabled;
  final owner = ValueNotifier<String?>('account-one');
  final updates = <bool>[];
  bool fail = false;
  Completer<void>? saving;
  int blockedUsersOpened = 0;

  Widget app({Locale locale = const Locale('en'), double scale = 1}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: ListenableBuilder(
          listenable: Listenable.merge([enabled, owner]),
          builder: (context, _) => Scaffold(
            appBar: AppBar(
              actions: [
                ChatsMenuButton(
                  owner: owner.value,
                  notificationsEnabled: enabled.value,
                  onBlockedUsers: () => blockedUsersOpened++,
                  onNotificationsChanged: (value) async {
                    updates.add(value);
                    await saving?.future;
                    if (fail) throw Exception('Save failed');
                    enabled.value = value;
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var permission = PermissionStatus.granted;
  var requestedPermission = PermissionStatus.granted;
  final permissionCalls = <String>[];
  setUp(() {
    permission = PermissionStatus.granted;
    requestedPermission = PermissionStatus.granted;
    permissionCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async {
            permissionCalls.add(call.method);
            if (call.method == 'checkPermissionStatus') return permission.index;
            if (call.method == 'requestPermissions') {
              return {Permission.notification.value: requestedPermission.index};
            }
            if (call.method == 'openAppSettings') return true;
            return null;
          },
        );
  });

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel preserves notifications and blocked-users action', (
    tester,
  ) async {
    final harness = _MenuHarness();
    await tester.pumpWidget(harness.app());
    await openMenu(tester);
    await tester.tap(find.text('Mute notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Mute chat notifications?'), findsOneWidget);
    expect(
      find.textContaining('incoming calls and AI reminders'),
      findsOneWidget,
    );
    expect(harness.updates, isEmpty);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(harness.enabled.value, isTrue);
    expect(harness.updates, isEmpty);
    expect(permissionCalls, isEmpty);
    await openMenu(tester);
    final l = AppLocalizations.of(
      tester.element(find.byType(ChatsMenuButton)),
    )!;
    await tester.tap(find.text(l.chatBlockedUsersMenu));
    await tester.pumpAndSettle();
    expect(harness.blockedUsersOpened, 1);
  });

  testWidgets(
    'confirm saves once and waits for server success before changing state',
    (tester) async {
      final harness = _MenuHarness()..saving = Completer<void>();
      await tester.pumpWidget(harness.app());
      await openMenu(tester);
      await tester.tap(find.text('Mute notifications'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Mute notifications'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(harness.updates, [false]);
      expect(harness.enabled.value, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      harness.saving!.complete();
      await tester.pumpAndSettle();
      expect(harness.enabled.value, isFalse);
      expect(permissionCalls, isEmpty);
      await openMenu(tester);
      expect(find.text('Enable notifications'), findsOneWidget);
    },
  );

  testWidgets('failed update reports error and preserves enabled state', (
    tester,
  ) async {
    final harness = _MenuHarness()..fail = true;
    await tester.pumpWidget(harness.app());
    await openMenu(tester);
    await tester.tap(find.text('Mute notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Mute notifications'));
    await tester.pumpAndSettle();
    expect(harness.enabled.value, isTrue);
    expect(harness.updates, [false]);
    final l = AppLocalizations.of(
      tester.element(find.byType(ChatsMenuButton)),
    )!;
    expect(find.text(l.chatNotificationUpdateFailed), findsOneWidget);
    await openMenu(tester);
    expect(find.text('Mute notifications'), findsOneWidget);
  });

  testWidgets('enable requests OS permission and uses the existing save flow', (
    tester,
  ) async {
    final harness = _MenuHarness(enabled: false);
    permission = PermissionStatus.denied;
    await tester.pumpWidget(harness.app());
    await openMenu(tester);
    await tester.tap(find.text('Enable notifications'));
    await tester.pumpAndSettle();
    expect(permissionCalls, ['checkPermissionStatus', 'requestPermissions']);
    expect(harness.updates, [true]);
    expect(harness.enabled.value, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('denied permission keeps the account switch off', (tester) async {
    final harness = _MenuHarness(enabled: false);
    permission = PermissionStatus.permanentlyDenied;
    requestedPermission = PermissionStatus.permanentlyDenied;
    await tester.pumpWidget(harness.app());
    await openMenu(tester);
    await tester.tap(find.text('Enable notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications disabled'), findsOneWidget);
    final l = AppLocalizations.of(
      tester.element(find.byType(ChatsMenuButton)),
    )!;
    expect(find.text(l.permissionsOpenSettings), findsOneWidget);
    expect(harness.updates, isEmpty);
    expect(harness.enabled.value, isFalse);
  });

  testWidgets('confirmation cannot update a different account', (tester) async {
    final harness = _MenuHarness();
    await tester.pumpWidget(harness.app());
    await openMenu(tester);
    await tester.tap(find.text('Mute notifications'));
    await tester.pumpAndSettle();
    harness.owner.value = 'account-two';
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Mute notifications'));
    await tester.pumpAndSettle();
    expect(harness.updates, isEmpty);
    expect(harness.enabled.value, isTrue);
  });

  testWidgets('menu and confirmation fit all locales on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 650);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final harness = _MenuHarness();
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(harness.app(locale: locale, scale: 1.3));
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(
        tester.element(find.byType(ChatsMenuButton)),
      )!;
      await openMenu(tester);
      await tester.tap(find.text(l.chatMuteNotifications));
      await tester.pumpAndSettle();
      expect(find.text(l.chatDisableAllNotificationsTitle), findsOneWidget);
      expect(
        find
            .widgetWithText(FilledButton, l.chatMuteNotifications)
            .hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull, reason: locale.toString());
      await tester.tap(find.text(l.cancel));
      await tester.pumpAndSettle();
    }
    expect(harness.updates, isEmpty);
  });
}
