// auth_interceptor.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';

import 'token_storage.dart';

class TokenInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  TokenInterceptor(this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await tokenStorage.getToken(); // "email:api_key" (Basic)
      final sessionId = await tokenStorage.getSessionId(); // __Host-sessionid
      // final sessionId = '1q70y5fkp4ym8iffann3pmwzn8rc508m'; // __Host-sessionid

      // --- 1) Basic auth, если доступно — короткий путь, CSRF не нужен ---
      if (token != null && token.contains(':')) {
        final auth = base64Encode(utf8.encode(token));
        options.headers['Authorization'] = 'Basic $auth';
        options.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01';
        return handler.next(options);
      }

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
