import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';

class OrgTokenInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final String baseUrl;

  OrgTokenInterceptor({required this.tokenStorage, required this.baseUrl});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final String? raw = await tokenStorage.getToken(baseUrl); // "email:api_key"
      if (raw != null && raw.contains(':')) {
        final String basic = base64Encode(utf8.encode(raw));
        options.headers['Authorization'] = 'Basic $basic';
        options.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01';
      }
    } catch (_) {}
    handler.next(options);
  }
}
