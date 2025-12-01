import 'package:dio/dio.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';

class OrgCsrfCookieInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final String baseUrl;

  OrgCsrfCookieInterceptor({required this.tokenStorage, required this.baseUrl});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final String? csrfToken = await tokenStorage.getCsrftoken(baseUrl);

      final String? existingCookie = (options.headers['Cookie'] as String?)?.trim();
      final List<String> cookieParts = <String>[];
      if (existingCookie != null && existingCookie.isNotEmpty) {
        cookieParts.add(existingCookie);
      }
      cookieParts.add('django_language=ru');

      if (csrfToken != null && csrfToken.isNotEmpty) {
        cookieParts.add('__Host-csrftoken=$csrfToken');
        options.headers['X-CSRFToken'] = csrfToken;
        options.headers['Referer'] = baseUrl;
      }

      if (cookieParts.isNotEmpty) {
        options.headers['Cookie'] = _normalizeCookie(cookieParts.join('; '));
      }
    } catch (_) {}

    handler.next(options);
  }

  String _normalizeCookie(String cookie) {
    final Set<String> seen = <String>{};
    final List<String> parts = cookie
        .split(';')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .where((String e) => seen.add(e))
        .toList();
    return parts.join('; ');
  }
}
