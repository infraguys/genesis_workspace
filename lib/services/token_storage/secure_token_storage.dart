import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;

  static const String _scopesKey = 'token_storage_scopes';

  SecureTokenStorage(this._storage);

  String _encodeScope(String baseUrl) {
    final encoded = base64Url.encode(utf8.encode(baseUrl.trim()));
    return encoded.replaceAll('=', '');
  }

  String _buildKey(String prefix, String baseUrl) {
    final scope = _encodeScope(baseUrl);
    return '$prefix::$scope';
  }

  Future<Set<String>> _loadScopes() async {
    final raw = await _storage.read(key: _scopesKey);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<String>().toSet();
    } catch (e) {
      inspect(e);
      return <String>{};
    }
  }

  Future<void> _persistScopes(Set<String> scopes) {
    return _storage.write(key: _scopesKey, value: jsonEncode(scopes.toList()));
  }

  Future<void> _registerScope(String baseUrl) async {
    final scopes = await _loadScopes();
    if (scopes.add(baseUrl)) {
      await _persistScopes(scopes);
    }
  }

  Future<void> _unregisterScope(String baseUrl) async {
    final scopes = await _loadScopes();
    if (scopes.remove(baseUrl)) {
      await _persistScopes(scopes);
    }
  }

  Future<void> _pruneScope(String baseUrl) async {
    final token = await _storage.read(key: _buildKey(TokenStorageKeys.token, baseUrl));
    final session = await _storage.read(key: _buildKey(TokenStorageKeys.sessionId, baseUrl));
    final csrf = await _storage.read(key: _buildKey(TokenStorageKeys.csrftoken, baseUrl));
    if ((token == null || token.isEmpty) &&
        (session == null || session.isEmpty) &&
        (csrf == null || csrf.isEmpty)) {
      await _unregisterScope(baseUrl);
    }
  }

  @override
  Future<void> saveToken({
    required String baseUrl,
    required String token,
    required String email,
  }) async {
    try {
      await _registerScope(baseUrl);
      await _storage.write(key: _buildKey(TokenStorageKeys.token, baseUrl), value: "$email:$token");
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveSessionIdCookie({required String baseUrl, required String sessionId}) async {
    try {
      await _registerScope(baseUrl);
      await _storage.write(key: _buildKey(TokenStorageKeys.sessionId, baseUrl), value: sessionId);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveCsrfTokenCookie({required String baseUrl, required String csrftoken}) async {
    try {
      await _registerScope(baseUrl);
      await _storage.write(key: _buildKey(TokenStorageKeys.csrftoken, baseUrl), value: csrftoken);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<String?> getToken(String baseUrl) =>
      _storage.read(key: _buildKey(TokenStorageKeys.token, baseUrl));

  @override
  Future<String?> getCsrftoken(String baseUrl) =>
      _storage.read(key: _buildKey(TokenStorageKeys.csrftoken, baseUrl));

  @override
  Future<String?> getSessionId(String baseUrl) =>
      _storage.read(key: _buildKey(TokenStorageKeys.sessionId, baseUrl));

  @override
  Future<void> deleteToken(String baseUrl) async {
    await _storage.delete(key: _buildKey(TokenStorageKeys.token, baseUrl));
    await _pruneScope(baseUrl);
  }

  @override
  Future<void> deleteSessionId(String baseUrl) async {
    await _storage.delete(key: _buildKey(TokenStorageKeys.sessionId, baseUrl));
    await _pruneScope(baseUrl);
  }

  @override
  Future<void> deleteCsrfToken(String baseUrl) async {
    await _storage.delete(key: _buildKey(TokenStorageKeys.csrftoken, baseUrl));
    await _pruneScope(baseUrl);
  }

  @override
  Future<void> clearAll() async {
    final scopes = await _loadScopes();
    for (final scope in scopes) {
      await _storage.delete(key: _buildKey(TokenStorageKeys.token, scope));
      await _storage.delete(key: _buildKey(TokenStorageKeys.sessionId, scope));
      await _storage.delete(key: _buildKey(TokenStorageKeys.csrftoken, scope));
    }
    await _storage.delete(key: _scopesKey);
  }
}
