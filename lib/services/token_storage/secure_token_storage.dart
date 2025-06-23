import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';

import 'token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final _storage = getIt<FlutterSecureStorage>();

  @override
  Future<void> saveToken({required String token, required String email}) =>
      _storage.write(key: TokenStorageKeys.token, value: "$email:$token");

  @override
  Future<String?> getToken() => _storage.read(key: TokenStorageKeys.token);

  @override
  Future<void> deleteToken() => _storage.delete(key: TokenStorageKeys.token);
}
