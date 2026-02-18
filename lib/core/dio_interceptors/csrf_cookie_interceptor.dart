// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';

import '../../services/token_storage/token_storage.dart';

class CsrfCookieInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;
  CsrfCookieInterceptor(this.tokenStorage, this.dio);

  final _referer = AppConstants.baseUrl;
  static const Set<int> _csrfExpiredStatusCodes = <int>{403, 419};
  static const String _csrfRetryExtraKey = 'csrfRetryAttempted';
  static const String _csrfRefreshPath = '/accounts/login/';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final csrfToken = await tokenStorage.getCsrftoken(AppConstants.baseUrl); // __Host-csrftoken
      _appendCsrfHeaders(options.headers, csrfToken);
    } catch (e) {
      print('TokenInterceptor error: $e');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final int? statusCode = err.response?.statusCode;
    final bool isCsrfExpired = _csrfExpiredStatusCodes.contains(statusCode);
    final bool retryAttempted = err.requestOptions.extra[_csrfRetryExtraKey] == true;
    final bool isRefreshRequest = err.requestOptions.path.contains(_csrfRefreshPath);

    if (!isCsrfExpired || retryAttempted || isRefreshRequest) {
      handler.next(err);
      return;
    }

    final bool refreshed = await _refreshCsrfToken();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    try {
      final csrfToken = await tokenStorage.getCsrftoken(AppConstants.baseUrl);
      final updatedHeaders = Map<String, dynamic>.from(err.requestOptions.headers);
      _appendCsrfHeaders(updatedHeaders, csrfToken);

      final retryRequest = err.requestOptions.copyWith(
        headers: updatedHeaders,
        extra: {
          ...err.requestOptions.extra,
          _csrfRetryExtraKey: true,
        },
      );

      final response = await dio.fetch<dynamic>(retryRequest);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<bool> _refreshCsrfToken() async {
    try {
      final Response<dynamic> response = await dio.get<dynamic>(_csrfRefreshPath);
      final csrfToken = _extractCookieToken(response.headers['set-cookie'], '__Host-csrftoken');

      if (csrfToken == null || csrfToken.isEmpty) {
        return false;
      }

      await tokenStorage.saveCsrfTokenCookie(baseUrl: AppConstants.baseUrl, csrftoken: csrfToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _appendCsrfHeaders(Map<String, dynamic> headers, String? csrfToken) {
    final String? existingCookie = (headers['Cookie'] as String?)?.trim();
    final List<String> cookieParts = <String>[];
    if (existingCookie != null && existingCookie.isNotEmpty) {
      cookieParts.add(existingCookie);
    }
    cookieParts.add('django_language=ru');

    if (csrfToken != null && csrfToken.isNotEmpty) {
      cookieParts.add('__Host-csrftoken=$csrfToken');
      headers['X-CSRFToken'] = csrfToken;
      headers['Referer'] = _referer;
    }

    if (cookieParts.isNotEmpty) {
      headers['Cookie'] = _normalizeCookie(cookieParts.join('; '));
    }
  }

  String? _extractCookieToken(List<String>? rawCookies, String cookieName) {
    if (rawCookies == null) {
      return null;
    }

    for (final String cookie in rawCookies) {
      if (cookie.startsWith(cookieName)) {
        return RegExp('$cookieName=([^;]+)').firstMatch(cookie)?.group(1);
      }
    }
    return null;
  }

  // Убирает дубликаты и двойные разделители в Cookie
  String _normalizeCookie(String cookie) {
    final seen = <String>{};
    final parts = cookie.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).where((e) => seen.add(e)).toList();
    return parts.join('; ');
  }
}
