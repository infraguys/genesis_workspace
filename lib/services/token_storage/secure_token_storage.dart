import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';

import 'token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final _storage = getIt<FlutterSecureStorage>();

  @override
  Future<void> saveToken({required String token, required String email}) {
    try {
      return _storage.write(key: TokenStorageKeys.token, value: "$email:$token");
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveSessionIdCookie({required String sessionId}) async {
    try {
      await _storage.write(key: TokenStorageKeys.sessionId, value: sessionId);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveCsrfTokenCookie({required String csrftoken}) async {
    try {
      await _storage.write(key: TokenStorageKeys.csrftoken, value: csrftoken);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<String?> getToken() => _storage.read(key: TokenStorageKeys.token);

  @override
  Future<String?> getCsrftoken() => _storage.read(key: TokenStorageKeys.csrftoken);

  @override
  Future<String?> getSessionId() => _storage.read(key: TokenStorageKeys.sessionId);

  @override
  Future<void> deleteToken() => _storage.delete(key: TokenStorageKeys.token);

  @override
  Future<void> deleteSessionId() async {
    await Future.wait([
      _storage.delete(key: TokenStorageKeys.sessionId),
      _storage.delete(key: TokenStorageKeys.csrftoken),
    ]);
  }
}
