// file_token_storage.dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'token_storage.dart';

class FileTokenStorage implements TokenStorage {
  static const _authTokenFilename = 'auth_token.txt';
  static const _sessionIdFilename = 'session_id.txt';
  static const _csrftokenFilename = 'csrftoken.txt';

  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_authTokenFilename');
  }

  Future<File> _getSessionId() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_sessionIdFilename');
  }

  Future<File> _getCsrftoken() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_csrftokenFilename');
  }

  @override
  Future<void> saveToken({required String token, required String email}) async {
    final file = await _getFile();
    await file.writeAsString("$email:$token", flush: true);
  }

  @override
  Future<void> saveSessionIdCookie({required String sessionId}) async {
    final sessionIdFile = await _getSessionId();
    await sessionIdFile.writeAsString(sessionId, flush: true);
  }

  @override
  Future<void> saveCsrfTokenCookie({required String csrftoken}) async {
    final csrftokenFile = await _getCsrftoken();
    await csrftokenFile.writeAsString(csrftoken, flush: true);
  }

  @override
  Future<String?> getToken() async {
    final file = await _getFile();
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  @override
  Future<String?> getSessionId() async {
    final file = await _getSessionId();
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  @override
  Future<String?> getCsrftoken() async {
    final file = await _getCsrftoken();
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

  @override
  Future<void> deleteSessionId() async {
    final sessionId = await _getSessionId();
    final csrftoken = await _getCsrftoken();
    if (await sessionId.exists()) {
      await sessionId.delete();
    }
    if (await csrftoken.exists()) {
      await csrftoken.delete();
    }
  }
}
