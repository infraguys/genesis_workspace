// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';

class SessionIdInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  SessionIdInterceptor(this._tokenStorage);

  String _resolveStorageBaseUrl(RequestOptions options) {
    final String candidate = options.baseUrl.trim();
    if (candidate.isNotEmpty && !candidate.contains('placeholder.local')) {
      try {
        final Uri uri = Uri.parse(candidate);
        if (uri.hasScheme && uri.host.isNotEmpty) {
          final String portPart = uri.hasPort ? ':${uri.port}' : '';
          return '${uri.scheme}://${uri.host}$portPart';
        }
      } catch (_) {}
    }
    return AppConstants.baseUrl.trim();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final bool skipBaseUrlRewrite = options.extra['skipBaseUrlInterceptor'] == true;
      final String storageBaseUrl = _resolveStorageBaseUrl(options);
      final sessionId = await _tokenStorage.getSessionId(storageBaseUrl); // __Host-sessionid

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
        if (!skipBaseUrlRewrite && !options.baseUrl.contains('/workspace/')) {
          // Referer полезен и для GET сессии
          options.baseUrl = '$storageBaseUrl/json';
        }
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
    final parts = cookie.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).where((e) => seen.add(e)).toList();
    return parts.join('; ');
  }
}
