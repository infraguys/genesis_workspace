import 'package:dio/dio.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';

class OrgSessionIdInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final String baseUrl;

  OrgSessionIdInterceptor({required this.tokenStorage, required this.baseUrl});

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

  String _withBasePath(String currentBaseUrl, String basePath) {
    final Uri uri = Uri.parse(currentBaseUrl);
    return uri.replace(path: basePath).toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final String? sessionId = await tokenStorage.getSessionId(baseUrl);

      final String? existingCookie = (options.headers['Cookie'] as String?)?.trim();
      final List<String> cookieParts = <String>[];
      if (existingCookie != null && existingCookie.isNotEmpty) {
        cookieParts.add(existingCookie);
      }
      cookieParts.add('django_language=ru');

      if (sessionId != null && sessionId.isNotEmpty) {
        cookieParts.add('__Host-sessionid=$sessionId');

        if (!options.baseUrl.endsWith('/json')) {
          options.baseUrl = _withBasePath(options.baseUrl, '/json');
        }
      }

      if (cookieParts.isNotEmpty) {
        options.headers['Cookie'] = _normalizeCookie(cookieParts.join('; '));
      }
    } catch (_) {}

    handler.next(options);
  }
}
