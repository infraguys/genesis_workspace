import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';

import 'file_token_storage.dart';
import 'secure_token_storage.dart';

abstract class TokenStorage {
  Future<void> saveToken({required String token, required String email});
  Future<void> saveSessionIdCookie({required String sessionId});
  Future<void> saveCsrfTokenCookie({required String csrftoken});
  Future<String?> getToken();
  Future<String?> getSessionId();
  Future<String?> getCsrftoken();
  Future<void> deleteToken();
  Future<void> deleteSessionId();
  Future<void> deleteCsrfToken();
}

class TokenStorageFactory {
  static TokenStorage create() {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        kIsWeb) {
      return SecureTokenStorage(getIt<FlutterSecureStorage>());
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return FileTokenStorage();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

class TokenStorageKeys {
  static const String token = 'auth_token';
  static const String sessionId = 'session_id';
  static const String csrftoken = 'csrftoken';
}
