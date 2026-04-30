import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/apple_system_version.dart';
import '../../l10n/app_localizations.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  static const MethodChannel _networkChannel = MethodChannel(
    'bantera/network_reachability',
  );

  final Map<_PermissionKind, _PermissionDisplayStatus> _statuses = {};
  List<_RequiredPermission> _visiblePermissions = const [];
  bool _isLoading = true;

  static const _microphonePermission = _RequiredPermission(
    kind: _PermissionKind.microphone,
    permission: Permission.microphone,
    icon: Icons.mic_none,
    titleKey: _PermissionTextKey.microphoneTitle,
    descriptionKey: _PermissionTextKey.microphoneDescription,
  );

  static const _speechPermission = _RequiredPermission(
    kind: _PermissionKind.speech,
    permission: Permission.speech,
    icon: Icons.record_voice_over_outlined,
    titleKey: _PermissionTextKey.speechTitle,
    descriptionKey: _PermissionTextKey.speechDescription,
  );

  static const _mobileDataPermission = _RequiredPermission(
    kind: _PermissionKind.mobileData,
    icon: Icons.cell_tower_outlined,
    titleKey: _PermissionTextKey.mobileDataTitle,
    descriptionKey: _PermissionTextKey.mobileDataDescription,
  );

  List<_RequiredPermission> _buildVisiblePermissions(bool isIphone) {
    final permissions = <_RequiredPermission>[
      _microphonePermission,
      if (Platform.isIOS && isLegacyAppleOsPre26) _speechPermission,
      if (isIphone) _mobileDataPermission,
    ];
    return permissions;
  }

  static const _fallbackPermissions = <_RequiredPermission>[
    _RequiredPermission(
      kind: _PermissionKind.microphone,
      permission: Permission.microphone,
      icon: Icons.mic_none,
      titleKey: _PermissionTextKey.microphoneTitle,
      descriptionKey: _PermissionTextKey.microphoneDescription,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshStatuses());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshStatuses());
    }
  }

  Future<void> _refreshStatuses() async {
    if (!Platform.isIOS) {
      setState(() {
        _visiblePermissions = _fallbackPermissions;
        _isLoading = false;
      });
      return;
    }

    final isIphone = await _isIphoneDevice();
    final visiblePermissions = _buildVisiblePermissions(isIphone);
    final results = <_PermissionKind, _PermissionDisplayStatus>{};
    for (final row in visiblePermissions) {
      results[row.kind] = await row.status();
    }

    if (!mounted) return;
    setState(() {
      _statuses
        ..clear()
        ..addAll(results);
      _visiblePermissions = visiblePermissions;
      _isLoading = false;
    });
  }

  Future<bool> _isIphoneDevice() async {
    try {
      final response = await _networkChannel.invokeMapMethod<Object?, Object?>(
        'getDeviceInfo',
      );
      final model = response?['model']?.toString().toLowerCase() ?? '';
      final idiom =
          response?['userInterfaceIdiom']?.toString().toLowerCase() ?? '';
      return idiom == 'phone' && model.contains('iphone');
    } catch (_) {
      return false;
    }
  }

  static Future<_PermissionDisplayStatus> _mobileDataStatus() async {
    try {
      final raw = await _networkChannel.invokeMethod<String>(
        'getCellularRestrictedState',
      );
      return switch (raw) {
        'notRestricted' => _PermissionDisplayStatus.allowed,
        'restricted' => _PermissionDisplayStatus.notAllowed,
        _ => _PermissionDisplayStatus.unknown,
      };
    } catch (_) {
      return _PermissionDisplayStatus.unknown;
    }
  }

  Future<void> _handleAllow(_RequiredPermission row) async {
    final status = _statuses[row.kind] ?? _PermissionDisplayStatus.unknown;
    if (status == _PermissionDisplayStatus.notDetermined &&
        row.permission != null) {
      await row.permission!.request();
      await _refreshStatuses();
    } else {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appPermissionsTitle),
        actions: [
          IconButton(
            tooltip: l10n.permissionsRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => unawaited(_refreshStatuses()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.permissionsIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < _visiblePermissions.length;
                    index++
                  ) ...[
                    _PermissionTile(
                      row: _visiblePermissions[index],
                      status: _statuses[_visiblePermissions[index].kind],
                      onAllow: () => _handleAllow(_visiblePermissions[index]),
                    ),
                    if (index != _visiblePermissions.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.row,
    required this.status,
    required this.onAllow,
  });

  final _RequiredPermission row;
  final _PermissionDisplayStatus? status;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveStatus = status ?? _PermissionDisplayStatus.unknown;
    final colorScheme = Theme.of(context).colorScheme;
    final needsAction =
        effectiveStatus == _PermissionDisplayStatus.notDetermined ||
        effectiveStatus == _PermissionDisplayStatus.notAllowed;

    return ListTile(
      leading: Icon(row.icon, color: colorScheme.primary),
      title: Text(row.title(l10n)),
      subtitle: Text(row.description(l10n)),
      trailing: needsAction
          ? FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onAllow,
              child: Text(l10n.permissionActionAllow),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                _statusLabel(l10n, effectiveStatus),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: effectiveStatus == _PermissionDisplayStatus.allowed
                      ? colorScheme.primary
                      : colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }

  String _statusLabel(AppLocalizations l10n, _PermissionDisplayStatus status) {
    return switch (status) {
      _PermissionDisplayStatus.allowed => l10n.permissionStatusAllowed,
      _PermissionDisplayStatus.limited => l10n.permissionStatusLimited,
      _PermissionDisplayStatus.notDetermined => l10n.permissionStatusNotAllowed,
      _PermissionDisplayStatus.notAllowed => l10n.permissionStatusNotAllowed,
      _PermissionDisplayStatus.unknown => l10n.permissionStatusUnknown,
    };
  }
}

class _RequiredPermission {
  const _RequiredPermission({
    required this.kind,
    this.permission,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });

  final _PermissionKind kind;
  final Permission? permission;
  final IconData icon;
  final _PermissionTextKey titleKey;
  final _PermissionTextKey descriptionKey;

  String title(AppLocalizations l10n) => titleKey.resolve(l10n);

  String description(AppLocalizations l10n) => descriptionKey.resolve(l10n);

  Future<_PermissionDisplayStatus> status() async {
    if (kind == _PermissionKind.mobileData) {
      return _PermissionsScreenState._mobileDataStatus();
    }

    final result = await permission!.status;
    if (result.isGranted) return _PermissionDisplayStatus.allowed;
    if (result.isLimited) return _PermissionDisplayStatus.limited;
    if (result.isDenied) return _PermissionDisplayStatus.notDetermined;
    return _PermissionDisplayStatus.notAllowed;
  }
}

enum _PermissionKind { microphone, speech, mobileData }

enum _PermissionDisplayStatus { allowed, limited, notDetermined, notAllowed, unknown }

enum _PermissionTextKey {
  microphoneTitle,
  microphoneDescription,
  speechTitle,
  speechDescription,
  mobileDataTitle,
  mobileDataDescription;

  String resolve(AppLocalizations l10n) {
    return switch (this) {
      _PermissionTextKey.microphoneTitle => l10n.permissionMicrophoneTitle,
      _PermissionTextKey.microphoneDescription =>
        l10n.permissionMicrophoneDescription,
      _PermissionTextKey.speechTitle => l10n.permissionSpeechTitle,
      _PermissionTextKey.speechDescription => l10n.permissionSpeechDescription,
      _PermissionTextKey.mobileDataTitle => l10n.permissionMobileDataTitle,
      _PermissionTextKey.mobileDataDescription =>
        l10n.permissionMobileDataDescription,
    };
  }
}
