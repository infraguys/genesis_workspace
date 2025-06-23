import 'package:web/web.dart' as web;

import 'token_storage.dart';

class WebTokenStorage implements TokenStorage {
  static const _key = TokenStorageKeys.token;

  @override
  Future<void> saveToken(String token) async {
    web.document.cookie = '$_key=$token; path=/; secure;';
  }

  @override
  Future<String?> getToken() async {
    final cookies = web.document.cookie?.split(';') ?? [];
    for (final cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2 && parts[0] == _key) return parts[1];
    }
    return null;
  }

  @override
  Future<void> deleteToken() async {
    web.document.cookie = '$_key=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT;';
  }
}
