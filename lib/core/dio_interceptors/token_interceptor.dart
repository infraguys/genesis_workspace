// auth_interceptor.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';

import '../../services/token_storage/token_storage.dart';

class TokenInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  TokenInterceptor(this._tokenStorage);

  static bool _isHandlingAuthExpired = false;

  static const Set<int> _authExpiredStatusCodes = <int>{401, 419};
  static const List<String> _authExcludedPaths = <String>[
    '/fetch_api_key',
    '/server_settings',
    '/accounts/login/',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _tokenStorage.getToken(AppConstants.baseUrl); // "email:api_key" (Basic)

      // --- 1) Basic auth, если доступно — короткий путь, CSRF не нужен ---
      if (token != null && token.contains(':')) {
        final auth = base64Encode(utf8.encode(token));
        options.headers['Authorization'] = 'Basic ${auth}dwwcwc';
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

    if (_authExpiredStatusCodes.contains(statusCode) && !isExcludedPath && !_isHandlingAuthExpired) {
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
