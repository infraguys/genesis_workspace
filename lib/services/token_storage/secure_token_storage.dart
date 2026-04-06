import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;

  static const String _scopesKey = 'token_storage_scopes';

  SecureTokenStorage(this._storage);

  String _normalizeBaseUrl(String baseUrl) {
    final String trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    try {
      final Uri uri = Uri.parse(trimmed);
      if (uri.hasScheme && uri.host.isNotEmpty) {
        final String portPart = uri.hasPort ? ':${uri.port}' : '';
        return '${uri.scheme}://${uri.host}$portPart';
      }
    } catch (_) {}
    return trimmed;
  }

  Set<String> _baseUrlAliases(String baseUrl) {
    final String trimmed = baseUrl.trim();
    final String normalized = _normalizeBaseUrl(baseUrl);
    final Set<String> values = <String>{};

    if (trimmed.isNotEmpty) {
      values.add(trimmed);
      if (trimmed.endsWith('/')) {
        values.add(trimmed.substring(0, trimmed.length - 1));
      } else {
        values.add('$trimmed/');
      }
    }

    if (normalized.isNotEmpty) {
      values.add(normalized);
      if (normalized.endsWith('/')) {
        values.add(normalized.substring(0, normalized.length - 1));
      } else {
        values.add('$normalized/');
      }
    }

    values.removeWhere((value) => value.isEmpty);
    return values;
  }

  String _encodeScope(String baseUrl) {
    final encoded = base64Url.encode(utf8.encode(baseUrl.trim()));
    return encoded.replaceAll('=', '');
  }

  String _buildRawKey(String prefix, String baseUrl) {
    final scope = _encodeScope(baseUrl);
    return '$prefix::$scope';
  }

  String _buildKey(String prefix, String baseUrl) {
    return _buildRawKey(prefix, _normalizeBaseUrl(baseUrl));
  }

  Future<String?> _readValue(String prefix, String baseUrl) async {
    for (final String alias in _baseUrlAliases(baseUrl)) {
      final String? value = await _storage.read(key: _buildRawKey(prefix, alias));
      if (value != null && value.isNotEmpty) {
        final String canonicalKey = _buildKey(prefix, baseUrl);
        if (canonicalKey != _buildRawKey(prefix, alias)) {
          await _storage.write(key: canonicalKey, value: value);
        }
        return value;
      }
    }
    return null;
  }

  Future<void> _deleteAllAliases(String prefix, String baseUrl) async {
    for (final String alias in _baseUrlAliases(baseUrl)) {
      await _storage.delete(key: _buildRawKey(prefix, alias));
    }
  }

  Future<Set<String>> _loadScopes() async {
    final raw = await _storage.read(key: _scopesKey);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<String>().map(_normalizeBaseUrl).toSet();
    } catch (e) {
      inspect(e);
      return <String>{};
    }
  }

  Future<void> _persistScopes(Set<String> scopes) {
    return _storage.write(key: _scopesKey, value: jsonEncode(scopes.toList()));
  }

  Future<void> _registerScope(String baseUrl) async {
    final String normalized = _normalizeBaseUrl(baseUrl);
    final scopes = await _loadScopes();
    if (scopes.add(normalized)) {
      await _persistScopes(scopes);
    }
  }

  Future<void> _unregisterScope(String baseUrl) async {
    final String normalized = _normalizeBaseUrl(baseUrl);
    final scopes = await _loadScopes();
    if (scopes.remove(normalized)) {
      await _persistScopes(scopes);
    }
  }

  Future<void> _pruneScope(String baseUrl) async {
    final token = await _readValue(TokenStorageKeys.token, baseUrl);
    final session = await _readValue(TokenStorageKeys.sessionId, baseUrl);
    final csrf = await _readValue(TokenStorageKeys.csrftoken, baseUrl);
    if ((token == null || token.isEmpty) && (session == null || session.isEmpty) && (csrf == null || csrf.isEmpty)) {
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
      final String normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
      await _registerScope(normalizedBaseUrl);
      await _storage.write(key: _buildKey(TokenStorageKeys.token, normalizedBaseUrl), value: "$email:$token");
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveSessionIdCookie({required String baseUrl, required String sessionId}) async {
    try {
      final String normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
      await _registerScope(normalizedBaseUrl);
      await _storage.write(key: _buildKey(TokenStorageKeys.sessionId, normalizedBaseUrl), value: sessionId);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveCsrfTokenCookie({required String baseUrl, required String csrftoken}) async {
    try {
      final String normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
      await _registerScope(normalizedBaseUrl);
      await _storage.write(key: _buildKey(TokenStorageKeys.csrftoken, normalizedBaseUrl), value: csrftoken);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<String?> getToken(String baseUrl) => _readValue(TokenStorageKeys.token, baseUrl);

  @override
  Future<String?> getCsrftoken(String baseUrl) => _readValue(TokenStorageKeys.csrftoken, baseUrl);

  @override
  Future<String?> getSessionId(String baseUrl) => _readValue(TokenStorageKeys.sessionId, baseUrl);

  @override
  Future<void> deleteToken(String baseUrl) async {
    final String normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    await _deleteAllAliases(TokenStorageKeys.token, normalizedBaseUrl);
    await _pruneScope(normalizedBaseUrl);
  }

  @override
  Future<void> deleteSessionId(String baseUrl) async {
    final String normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    await _deleteAllAliases(TokenStorageKeys.sessionId, normalizedBaseUrl);
    await _pruneScope(normalizedBaseUrl);
  }

  @override
  Future<void> deleteCsrfToken(String baseUrl) async {
    final String normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    await _deleteAllAliases(TokenStorageKeys.csrftoken, normalizedBaseUrl);
    await _pruneScope(normalizedBaseUrl);
  }

  @override
  Future<void> clearAll() async {
    final scopes = await _loadScopes();
    for (final scope in scopes) {
      await _deleteAllAliases(TokenStorageKeys.token, scope);
      await _deleteAllAliases(TokenStorageKeys.sessionId, scope);
      await _deleteAllAliases(TokenStorageKeys.csrftoken, scope);
    }
    await _storage.delete(key: _scopesKey);
  }
}
