import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'file_token_storage.dart';
import 'secure_token_storage.dart';
import 'web_token_storage.dart';

abstract class TokenStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

class TokenStorageFactory {
  static TokenStorage create() {
    if (kIsWeb) {
      return WebTokenStorage();
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return SecureTokenStorage();
    } else if (Platform.isWindows || Platform.isLinux) {
      return FileTokenStorage();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

class TokenStorageKeys {
  static const String token = 'auth_token';
}
