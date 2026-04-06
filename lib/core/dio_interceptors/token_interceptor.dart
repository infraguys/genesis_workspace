// auth_interceptor.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';

class TokenInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  TokenInterceptor(this._tokenStorage);

  static bool _isHandlingAuthExpired = false;

  static const Set<int> _authExpiredStatusCodes = <int>{401};
  static const List<String> _authExcludedPaths = <String>[
    '/fetch_api_key',
    '/server_settings',
    '/accounts/login/',
    '/events',
  ];

  String? _headerValue(Map<String, dynamic> headers, String targetKey) {
    final dynamic directValue = headers[targetKey];
    if (directValue != null) {
      return directValue.toString();
    }

    final String lowerTargetKey = targetKey.toLowerCase();
    for (final MapEntry<String, dynamic> header in headers.entries) {
      if (header.key.toLowerCase() == lowerTargetKey && header.value != null) {
        return header.value.toString();
      }
    }
    return null;
  }

  bool _requestContainsAuth(RequestOptions options) {
    final String authorization = (_headerValue(options.headers, 'Authorization') ?? '').trim();
    final String cookie = (_headerValue(options.headers, 'Cookie') ?? '').trim();
    final bool hasSessionCookie = cookie.contains('__Host-sessionid=') || cookie.contains('sessionid=');

    return authorization.isNotEmpty || hasSessionCookie;
  }

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
      final String storageBaseUrl = _resolveStorageBaseUrl(options);
      final token = await _tokenStorage.getToken(storageBaseUrl); // "email:api_key" (Basic)

      // --- 1) Basic auth, если доступно — короткий путь, CSRF не нужен ---
      if (token != null && token.contains(':')) {
        final auth = base64Encode(utf8.encode(token));
        options.headers['Authorization'] = 'Basic $auth';
        options.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01';
        return handler.next(options);
      }
    } catch (e) {
      // ignore: avoid_print
      print('TokenInterceptor error: $e');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final int? statusCode = err.response?.statusCode;
    final String requestPath = err.requestOptions.path.toLowerCase();
    final bool isExcludedPath = _authExcludedPaths.any(requestPath.contains);
    final bool requestContainsAuth = _requestContainsAuth(err.requestOptions);

    if (_authExpiredStatusCodes.contains(statusCode) &&
        !isExcludedPath &&
        requestContainsAuth &&
        !_isHandlingAuthExpired) {
      _isHandlingAuthExpired = true;
      try {
        await getIt<AuthCubit>().logout();
      } catch (_) {} finally {
        _isHandlingAuthExpired = false;
      }
    }

    handler.next(err);
  }
}
