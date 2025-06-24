import 'package:flutter/foundation.dart';

import 'file_token_storage.dart';
import 'secure_token_storage.dart';

abstract class TokenStorage {
  Future<void> saveToken({required String token, required String email});
  Future<String?> getToken();
  Future<void> deleteToken();
}

class TokenStorageFactory {
  static TokenStorage create() {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        kIsWeb) {
      return SecureTokenStorage();
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
}
