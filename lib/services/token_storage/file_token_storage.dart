// file_token_storage.dart
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'token_storage.dart';

class FileTokenStorage implements TokenStorage {
  static const String _storageFolder = 'token_storage';
  static const String _tokenPrefix = 'auth_token';
  static const String _sessionPrefix = 'session_id';
  static const String _csrfPrefix = 'csrftoken';

  Future<Directory> _ensureDir() async {
    final dir = await getApplicationSupportDirectory();
    final storageDir = Directory('${dir.path}/$_storageFolder');
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    return storageDir;
  }

  String _encodeScope(String baseUrl) {
    final encoded = base64Url.encode(utf8.encode(baseUrl.trim()));
    return encoded.replaceAll('=', '');
  }

  Future<File> _fileFor(String prefix, String baseUrl) async {
    final dir = await _ensureDir();
    final scope = _encodeScope(baseUrl);
    return File('${dir.path}/$prefix-$scope.txt');
  }

  @override
  Future<void> saveToken({
    required String baseUrl,
    required String token,
    required String email,
  }) async {
    final file = await _fileFor(_tokenPrefix, baseUrl);
    await file.writeAsString("$email:$token", flush: true);
  }

  @override
  Future<void> saveSessionIdCookie({
    required String baseUrl,
    required String sessionId,
  }) async {
    final sessionIdFile = await _fileFor(_sessionPrefix, baseUrl);
    await sessionIdFile.writeAsString(sessionId, flush: true);
  }

  @override
  Future<void> saveCsrfTokenCookie({
    required String baseUrl,
    required String csrftoken,
  }) async {
    final csrftokenFile = await _fileFor(_csrfPrefix, baseUrl);
    await csrftokenFile.writeAsString(csrftoken, flush: true);
  }

  @override
  Future<String?> getToken(String baseUrl) async {
    final file = await _fileFor(_tokenPrefix, baseUrl);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  @override
  Future<String?> getSessionId(String baseUrl) async {
    final file = await _fileFor(_sessionPrefix, baseUrl);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  @override
  Future<String?> getCsrftoken(String baseUrl) async {
    final file = await _fileFor(_csrfPrefix, baseUrl);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  @override
  Future<void> deleteToken(String baseUrl) async {
    final file = await _fileFor(_tokenPrefix, baseUrl);
    if (await file.exists()) {
      await file.delete();
    }
    await _pruneDirectory();
  }

  @override
  Future<void> deleteSessionId(String baseUrl) async {
    final sessionId = await _fileFor(_sessionPrefix, baseUrl);
    if (await sessionId.exists()) {
      await sessionId.delete();
    }
    await _pruneDirectory();
  }

  @override
  Future<void> deleteCsrfToken(String baseUrl) async {
    final csrftoken = await _fileFor(_csrfPrefix, baseUrl);
    if (await csrftoken.exists()) {
      await csrftoken.delete();
    }
    await _pruneDirectory();
  }

  Future<void> _pruneDirectory() async {
    final dir = await _ensureDir();
    if (await dir.exists()) {
      final entries = dir.listSync();
      if (entries.isEmpty) {
        await dir.delete(recursive: true);
      }
    }
  }

  @override
  Future<void> clearAll() async {
    final dir = await _ensureDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
