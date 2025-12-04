import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  BaseUrlInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool skipBaseUrlRewrite = options.extra['skipBaseUrlInterceptor'] == true;
    if (skipBaseUrlRewrite) {
      super.onRequest(options, handler);
      return;
    }

    //skip base endpoints
    if (options.baseUrl.contains('/workspace/')) {
      super.onRequest(options, handler);
      return;
    }

    final String? saved = _prefs.getString(SharedPrefsKeys.baseUrl);

    if (saved == null || saved.trim().isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          error: 'Base URL is not set. Navigate to PasteBaseUrl first.',
        ),
      );
      return;
    }

    final bool isWebAuth = _prefs.getBool(SharedPrefsKeys.isWebAuth) ?? false;
    final String basePath = (kIsWeb && isWebAuth) ? '/json' : '/api/v1';
    final String normalized = saved.trim();

    final String desired = '$normalized$basePath';
    if (options.baseUrl != desired) {
      options.baseUrl = desired;
    }

    super.onRequest(options, handler);
  }
}
