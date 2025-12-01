// auth_interceptor.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';

import '../../services/token_storage/token_storage.dart';

class TokenInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  TokenInterceptor(this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _tokenStorage.getToken(AppConstants.baseUrl); // "email:api_key" (Basic)

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
}
