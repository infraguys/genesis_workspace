// auth_interceptor.dart
import 'dart:convert';

import 'package:dio/dio.dart';

import 'token_storage.dart';

class TokenInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  TokenInterceptor(this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await tokenStorage.getToken();
      if (token != null && token.contains(':')) {
        final auth = base64Encode(utf8.encode(token)); // token = email:api_key
        options.headers['Authorization'] = 'Basic $auth';
      }
    } catch (e) {
      print('TokenInterceptor error: $e');
    }

    return handler.next(options);
  }
}
