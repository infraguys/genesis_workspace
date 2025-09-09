// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlInterceptor extends Interceptor {
  BaseUrlInterceptor(this._prefs);
  final SharedPreferences _prefs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? saved = _prefs.getString(SharedPrefsKeys.baseUrl);

    if (saved == null || saved.trim().isEmpty) {
      // Запросы до ввода baseUrl — это логическая ошибка навигации, аккуратно подсветим.
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

    // Если кто-то уже поменял baseUrl через saveBaseUrl — просто синхронизируем.
    final String desired = '$normalized$basePath';
    if (options.baseUrl != desired) {
      options.baseUrl = desired;
    }

    super.onRequest(options, handler);
  }
}
