import 'dart:io';
import 'package:app/infrastructure/app_storage_service.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/storage_cache_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Storage extends AppStorageService {
  _Storage()
    : super(
        roots: [],
        temporary: Directory('/unused'),
        support: Directory('/unused'),
        clearImages: () async {},
        clearSnapshots: () async {},
      );
  int clears = 0;
  @override
  Future<StorageUsage> scan() async => StorageUsage({
    for (final category in StorageCategory.values) category: 12000000,
  }, clears == 0 ? {StorageCategory.images: 12000000} : {});
  @override
  Future<StorageUsage> clearSafeCache() async {
    clears++;
    return scan();
  }
}

Widget app(
  Widget page, {
  Locale locale = const Locale('en'),
  double scale = 1,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: page,
);
void main() {
  testWidgets('clearing requires confirmation and refreshes measured usage', (
    tester,
  ) async {
    final service = _Storage();
    await tester.pumpWidget(app(StorageCacheScreen(service: service)));
    await tester.pumpAndSettle();
    expect(find.text('84.0 MB'), findsOneWidget);
    await tester.tap(find.text('Clear cache').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(service.clears, 0);
    await tester.tap(find.text('Clear cache').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear cache').last);
    await tester.pumpAndSettle();
    expect(service.clears, 1);
    expect(find.text('Safe to clear: 0 MB'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
      isNull,
    );
  });
  testWidgets(
    'storage categories fit small screens and large text in every locale',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(
          app(
            StorageCacheScreen(key: ValueKey(locale), service: _Storage()),
            locale: locale,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: locale.toLanguageTag());
      }
    },
  );
}
