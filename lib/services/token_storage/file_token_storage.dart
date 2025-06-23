// file_token_storage.dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'token_storage.dart';

class FileTokenStorage implements TokenStorage {
  static const _filename = 'auth_token.txt';

  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_filename');
  }

  @override
  Future<void> saveToken(String token) async {
    final file = await _getFile();
    await file.writeAsString(token, flush: true);
  }

  @override
  Future<String?> getToken() async {
    final file = await _getFile();
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  @override
  Future<void> deleteToken() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
