// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';

import '../../services/token_storage/token_storage.dart';

class SessionidInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  SessionidInterceptor(this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final sessionId = await _tokenStorage.getSessionId(); // __Host-sessionid

      // Текущий Cookie (если уже что-то есть — не перетираем)
      final existingCookie = (options.headers['Cookie'] as String?)?.trim();
      final cookieParts = <String>[];
      if (existingCookie != null && existingCookie.isNotEmpty) {
        cookieParts.add(existingCookie);
      }
      cookieParts.add('django_language=ru');

      // --- 2) sessionid: добавляем только его (независимо от CSRF) ---
      if (sessionId != null && sessionId.isNotEmpty) {
        cookieParts.add('__Host-sessionid=$sessionId');
        // Referer полезен и для GET сессии
        options.baseUrl = '${AppConstants.baseUrl}/json';
      }
      if (cookieParts.isNotEmpty) {
        // Склеиваем без дубликатов и лишних ; ;
        options.headers['Cookie'] = _normalizeCookie(cookieParts.join('; '));
      }
    } catch (e) {
      // ignore: avoid_print
      print('TokenInterceptor error: $e');
    }

    handler.next(options);
  }

  // Убирает дубликаты и двойные разделители в Cookie
  String _normalizeCookie(String cookie) {
    final seen = <String>{};
    final parts = cookie
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => seen.add(e))
        .toList();
    return parts.join('; ');
  }
}
