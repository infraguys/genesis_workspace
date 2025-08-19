// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';

import 'token_storage.dart';

class CsrfCookieInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  CsrfCookieInterceptor(this.tokenStorage);

  final _referer = AppConstants.baseUrl;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final csrfToken = await tokenStorage.getCsrftoken(); // __Host-csrftoken
      // final csrfToken = 'KI4WN2GNSMJWsZlCvKhrNJt5sGWWn6xH'; // __Host-csrftoken

      // Текущий Cookie (если уже что-то есть — не перетираем)
      final existingCookie = (options.headers['Cookie'] as String?)?.trim();
      final cookieParts = <String>[];
      if (existingCookie != null && existingCookie.isNotEmpty) {
        cookieParts.add(existingCookie);
      }
      cookieParts.add('django_language=ru');

      if (csrfToken != null && csrfToken.isNotEmpty) {
        cookieParts.add('__Host-csrftoken=$csrfToken');
        options.headers['X-CSRFToken'] = csrfToken;
        options.headers['Referer'] = _referer;
      }

      if (cookieParts.isNotEmpty) {
        options.headers['Cookie'] = _normalizeCookie(cookieParts.join('; '));
      }
    } catch (e) {
      print('TokenInterceptor error: $e');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Автосохранение Set-Cookie
    // try {
    //   final setCookies = response.headers.map['set-cookie'];
    //   if (setCookies != null) {
    //     for (final raw in setCookies) {
    //       final first = raw.split(';').first; // name=value
    //       final eq = first.indexOf('=');
    //       if (eq <= 0) continue;
    //       final name = first.substring(0, eq).trim();
    //       final value = first.substring(eq + 1).trim();
    //
    //       if (name == '__Host-csrftoken') {
    //         await tokenStorage.saveCsrfTokenCookie(csrftoken: value);
    //       } else if (name == '__Host-sessionid') {
    //         await tokenStorage.saveSessionIdCookie(sessionId: value);
    //       }
    //     }
    //   }
    // } catch (_) {}
    handler.next(response);
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
