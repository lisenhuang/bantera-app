import 'dart:developer' show log;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Result of classifying connectivity from local signals only (no HTTP/API).
enum NetworkIssueKind {
  /// iOS: per-app cellular denied and no Wi‑Fi/Ethernet path — user should enable
  /// Mobile Data for Bantera or connect to Wi‑Fi.
  cellularBlockedNoWifi,

  /// Any other unreachable case — generic user-facing copy.
  offlineGeneric,
}

enum _IosCellularPolicy { restricted, notRestricted, unknown }

/// Uses connectivity_plus and (on iOS) CoreTelephony `CTCellularData` via a MethodChannel.
class NetworkReachability {
  NetworkReachability._();

  static const MethodChannel _channel =
      MethodChannel('bantera/network_reachability');

  /// Classifies using only on-device state: [Connectivity] plus (on iOS)
  /// `CTCellularData` / `NWPathMonitor` via the platform channel.
  ///
  /// Does not perform any network request. Safe to call from UI (e.g. auth screen)
  /// before login.
  ///
  /// On non-iOS platforms, always returns [NetworkIssueKind.offlineGeneric].
  static Future<NetworkIssueKind> classifyLocalConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final hasWifiOrEthernet = results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);

    void trace(String msg) {
      log(msg, name: 'BanteraNetwork');
      if (kDebugMode) {
        debugPrint('[BanteraNetwork] $msg');
      }
    }

    trace(
      'classify: platform=${Platform.operatingSystem} '
      'connectivity=$results hasWifiOrEthernet=$hasWifiOrEthernet',
    );

    if (!Platform.isIOS) {
      trace('classify -> offlineGeneric (not iOS)');
      return NetworkIssueKind.offlineGeneric;
    }

    final hints = await _iosNetworkHints();
    trace(
      'classify: ct=${hints.ct} nwDef=${hints.nwDefaultSatisfied} '
      'nwWifi=${hints.nwWifiSatisfied} nwCell=${hints.nwCellularSatisfied}',
    );

    if (hints.ct == _IosCellularPolicy.restricted && !hasWifiOrEthernet) {
      trace('classify -> cellularBlockedNoWifi (CT restricted)');
      return NetworkIssueKind.cellularBlockedNoWifi;
    }

    // When `CTCellularData` stays `.restrictedStateUnknown` (common on recent iOS if
    // policy is read off the main thread or before the notifier fires), combine
    // `NWPathMonitor` with connectivity: no Wi‑Fi/Ethernet from the app and no
    // satisfied default path strongly suggests the per-app cellular toggle or
    // airplane mode — we still show the cellular-settings guidance in that narrow case.
    if (hints.ct == _IosCellularPolicy.unknown &&
        !hasWifiOrEthernet &&
        !hints.nwDefaultSatisfied &&
        !hints.nwWifiSatisfied &&
        !hints.nwCellularSatisfied) {
      trace('classify -> cellularBlockedNoWifi (NW snapshot fallback, CT unknown)');
      return NetworkIssueKind.cellularBlockedNoWifi;
    }

    trace('classify -> offlineGeneric');
    return NetworkIssueKind.offlineGeneric;
  }

  /// Same as [classifyLocalConnectivity]; kept for call sites that classify
  /// after a [SocketException].
  static Future<NetworkIssueKind> classifyAfterSocketFailure() =>
      classifyLocalConnectivity();

  static Future<_IosNetworkHints> _iosNetworkHints() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('getNetworkHints');
      if (raw is! Map) {
        log('getNetworkHints: unexpected payload type=${raw.runtimeType}',
            name: 'BanteraNetwork');
        return const _IosNetworkHints(
          ct: _IosCellularPolicy.unknown,
          nwDefaultSatisfied: false,
          nwWifiSatisfied: false,
          nwCellularSatisfied: false,
        );
      }
      final map = raw.cast<Object?, Object?>();
      final ctRaw = map['ctState'] as String?;
      final ct = switch (ctRaw) {
        'restricted' => _IosCellularPolicy.restricted,
        'notRestricted' => _IosCellularPolicy.notRestricted,
        _ => _IosCellularPolicy.unknown,
      };
      return _IosNetworkHints(
        ct: ct,
        nwDefaultSatisfied: _boolish(map['nwDefaultSatisfied']),
        nwWifiSatisfied: _boolish(map['nwWifiSatisfied']),
        nwCellularSatisfied: _boolish(map['nwCellularSatisfied']),
      );
    } on PlatformException catch (e, st) {
      log(
        'getNetworkHints PlatformException: $e',
        name: 'BanteraNetwork',
        stackTrace: st,
      );
      return const _IosNetworkHints(
        ct: _IosCellularPolicy.unknown,
        nwDefaultSatisfied: false,
        nwWifiSatisfied: false,
        nwCellularSatisfied: false,
      );
    } catch (e, st) {
      log('getNetworkHints: $e', name: 'BanteraNetwork', stackTrace: st);
      return const _IosNetworkHints(
        ct: _IosCellularPolicy.unknown,
        nwDefaultSatisfied: false,
        nwWifiSatisfied: false,
        nwCellularSatisfied: false,
      );
    }
  }

  static bool _boolish(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }
}

class _IosNetworkHints {
  const _IosNetworkHints({
    required this.ct,
    required this.nwDefaultSatisfied,
    required this.nwWifiSatisfied,
    required this.nwCellularSatisfied,
  });

  final _IosCellularPolicy ct;
  final bool nwDefaultSatisfied;
  final bool nwWifiSatisfied;
  final bool nwCellularSatisfied;
}
