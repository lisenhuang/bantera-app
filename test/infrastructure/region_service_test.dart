import 'package:app/infrastructure/region_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseTraceCountry', () {
    test('reads the loc line', () {
      const body =
          'fl=46f85\nh=api.bantera.app\nip=1.2.3.4\nloc=CN\ntls=TLSv1.3\n';
      expect(RegionService.parseTraceCountry(body), 'CN');
    });

    test('returns null when missing or malformed', () {
      expect(RegionService.parseTraceCountry('fl=1\nh=x\n'), isNull);
      expect(RegionService.parseTraceCountry('loc=\n'), isNull);
      expect(RegionService.parseTraceCountry('loc=XX1\n'), isNull);
    });
  });

  group('isTaiwanChineseLocale', () {
    test('matches every spelling of Chinese (Taiwan)', () {
      for (final id in ['zh-TW', 'zh_TW', 'zh-Hant-TW', 'ZH-tw']) {
        expect(RegionService.isTaiwanChineseLocale(id), isTrue, reason: id);
      }
    });

    test('keeps other Chinese variants', () {
      for (final id in ['zh', 'zh-CN', 'zh-HK', 'zh-Hant', 'yue-CN', 'en-TW']) {
        expect(RegionService.isTaiwanChineseLocale(id), isFalse, reason: id);
      }
    });
  });
}
