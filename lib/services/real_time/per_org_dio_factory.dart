import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:genesis_workspace/core/dio_interceptors/real_time/real_time_interceptors.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';

enum BasePathMode { apiV1, json }

class PerOrganizationDioFactory {
  const PerOrganizationDioFactory();

  Dio build({
    required String originBaseUrl,
    required TokenStorage tokenStorage,
    bool? isWebAuthOverride,
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 65),
  }) {
    final BasePathMode basePathMode = _resolveBasePathMode(
      originBaseUrl: originBaseUrl,
      tokenStorage: tokenStorage,
      isWebAuthOverride: isWebAuthOverride,
    );

    final String resolvedBaseUrl = _composeBaseUrl(
      originBaseUrl: originBaseUrl,
      mode: basePathMode,
    );

    final BaseOptions baseOptions = BaseOptions(
      baseUrl: resolvedBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      validateStatus: (int? statusCode) =>
          statusCode != null && statusCode >= 200 && statusCode < 600,
    );

    final Dio dio = Dio(baseOptions);

    // Порядок важен: сначала Basic, затем session, затем csrf.
    dio.interceptors.addAll([
      OrgTokenInterceptor(tokenStorage: tokenStorage, baseUrl: originBaseUrl),
      OrgSessionIdInterceptor(tokenStorage: tokenStorage, baseUrl: originBaseUrl),
      OrgCsrfCookieInterceptor(tokenStorage: tokenStorage, baseUrl: originBaseUrl),
    ]);

    // Для Web: с кукoй через браузерный адаптер обычно требуется withCredentials=true.
    if (kIsWeb) {
      final dynamic adapter = dio.httpClientAdapter;
      try {
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        adapter as HttpClientAdapter;
        // Некоторые адаптеры имеют флаг withCredentials, но это зависит от реализации.
        // Если у тебя свой WebAdapter — выставь там.
      } catch (_) {}
    }

    return dio;
  }

  BasePathMode _resolveBasePathMode({
    required String originBaseUrl,
    required TokenStorage tokenStorage,
    required bool? isWebAuthOverride,
  }) {
    if (isWebAuthOverride != null) {
      return isWebAuthOverride ? BasePathMode.json : BasePathMode.apiV1;
    }
    // Эвристика: если есть токен (Basic) — /api/v1; иначе если есть session/csrf и мы в web — /json; иначе /api/v1.
    return BasePathMode.apiV1;
  }

  String _composeBaseUrl({required String originBaseUrl, required BasePathMode mode}) {
    final Uri origin = Uri.parse(originBaseUrl);
    final String path = (mode == BasePathMode.json) ? '/json' : '/api/v1';
    return origin.replace(path: path).toString();
  }
}
