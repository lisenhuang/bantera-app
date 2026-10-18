import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'auth_session_notifier.dart';

class AiConsentRequired implements Exception {
  const AiConsentRequired();
}

/// Explicit, versioned permission, separate from the old dismissible notice.
/// Consent belongs to one account on one device. No prompt is shown by a
/// background request: callers must request permission from a user action.
class AiConsent extends ChangeNotifier {
  AiConsent({required this.currentOwner, required this.directory});

  static final instance = AiConsent(
    currentOwner: () => AuthSessionNotifier.instance.session?.cacheKey,
    directory: getApplicationSupportDirectory,
  );
  static const version = 1;
  final String? Function() currentOwner;
  final Future<Directory> Function() directory;
  Future<bool> Function()? present;
  final Map<String, Future<bool>> _loaded = {};
  final Map<String, bool> _allowed = {};
  final Map<String, int> _epochs = {};
  final Map<String, Future<bool>> _requests = {};

  Future<File> _file(String owner) async {
    final root = await directory();
    final key = base64Url.encode(utf8.encode(owner)).replaceAll('=', '');
    return File('${root.path}/ai-consent-$key.json');
  }

  bool isKnownAllowed(String owner) =>
      currentOwner() == owner && _allowed[owner] == true;

  Future<bool> isAllowed(String owner) async {
    if (currentOwner() != owner) return false;
    await (_loaded[owner] ??= _load(owner));
    return currentOwner() == owner && _allowed[owner] == true;
  }

  Future<bool> _load(String owner) async {
    final epoch = _epochs[owner] ?? 0;
    var allowed = false;
    try {
      final saved = jsonDecode(await (await _file(owner)).readAsString());
      allowed =
          saved is Map &&
          saved['version'] == version &&
          saved['allowed'] == true &&
          DateTime.tryParse(saved['updatedAt']?.toString() ?? '') != null;
    } catch (_) {
      // Missing, corrupt or inaccessible storage is never permission.
    }
    if ((_epochs[owner] ?? 0) == epoch) _allowed[owner] = allowed;
    return allowed;
  }

  Future<bool> request() async {
    final owner = currentOwner();
    if (owner == null) return false;
    if (await isAllowed(owner)) return true;
    if (currentOwner() != owner) return false;
    final pending = _requests[owner];
    if (pending != null) return pending;
    final request = _request(owner);
    _requests[owner] = request;
    try {
      return await request;
    } finally {
      _requests.remove(owner);
    }
  }

  Future<bool> _request(String owner) async {
    final epoch = _epochs[owner] ?? 0;
    if (await present?.call() != true ||
        currentOwner() != owner ||
        (_epochs[owner] ?? 0) != epoch) {
      return false;
    }
    try {
      final file = await _file(owner);
      if (currentOwner() != owner || (_epochs[owner] ?? 0) != epoch) {
        return false;
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({
          'version': version,
          'allowed': true,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        }),
        flush: true,
      );
      if (currentOwner() != owner || (_epochs[owner] ?? 0) != epoch) {
        await file.delete();
        return false;
      }
      _allowed[owner] = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> require(String owner) async {
    if (!await isAllowed(owner)) throw const AiConsentRequired();
  }

  Future<void> requireCurrent() async {
    final owner = currentOwner();
    if (owner == null) throw const AiConsentRequired();
    await require(owner);
  }

  Future<void> revoke() async {
    final owner = currentOwner();
    if (owner == null) return;
    _epochs[owner] = (_epochs[owner] ?? 0) + 1;
    _allowed[owner] = false;
    notifyListeners(); // Stop active streams immediately, before disk I/O.
    final file = await _file(owner);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'version': version,
        'allowed': false,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }),
      flush: true,
    );
  }
}
