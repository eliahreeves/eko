import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReliableSupabaseSessionStorage extends LocalStorage {
  ReliableSupabaseSessionStorage({required this.persistSessionKey});

  final String persistSessionKey;
  final Completer<void> _ready = Completer<void>();
  late final File _sessionFile;

  @override
  Future<void> initialize() async {
    final dir = await getApplicationSupportDirectory();
    final storageDir = Directory('${dir.path}/supabase_auth');
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    _sessionFile = File('${storageDir.path}/$persistSessionKey.session');
    if (!_ready.isCompleted) {
      _ready.complete();
    }
  }

  Future<void> _ensureReady() => _ready.future;

  @override
  Future<bool> hasAccessToken() async {
    await _ensureReady();
    if (!await _sessionFile.exists()) return false;
    final value = await _sessionFile.readAsString();
    return value.isNotEmpty;
  }

  @override
  Future<String?> accessToken() async {
    await _ensureReady();
    if (!await _sessionFile.exists()) return null;
    final value = await _sessionFile.readAsString();
    return value.isEmpty ? null : value;
  }

  @override
  Future<void> removePersistedSession() async {
    await _ensureReady();
    for (var i = 0; i < 3; i++) {
      if (await _sessionFile.exists()) {
        await _sessionFile.delete();
      }
      if (!await _sessionFile.exists()) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _ensureReady();
    for (var i = 0; i < 3; i++) {
      await _sessionFile.writeAsString(persistSessionString, flush: true);
      final persisted = await _sessionFile.readAsString();
      if (persisted == persistSessionString) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }
}
