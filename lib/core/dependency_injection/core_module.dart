import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dio_adapters/stub_adapter.dart'
    if (dart.library.html) 'package:genesis_workspace/core/dio_adapters/web_adapter.dart'
    if (dart.library.io) 'package:genesis_workspace/core/dio_adapters/io_adapter.dart';
import 'package:genesis_workspace/core/dio_interceptors/base_url_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/csrf_cookie_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/enum_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/sessionid_interceptor.dart';
import 'package:genesis_workspace/core/dio_interceptors/token_interceptor.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/navigation/app_shell_controller.dart';
import 'package:genesis_workspace/services/token_storage/secure_token_storage.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class CoreModule {
  @lazySingleton
  AppShellController provideAppShellController() => AppShellController();

  @lazySingleton
  AppDatabase appDatabase() => AppDatabase();

  @preResolve
  @lazySingleton
  Future<SharedPreferences> sharedPreferences() => SharedPreferences.getInstance();

  @lazySingleton
  Dio dio(SharedPreferences sharedPreferences, TokenStorage tokenStorage, DioFactory dioFactory) {
    final String? saved = sharedPreferences.getString(SharedPrefsKeys.baseUrl);
    final String baseUrl = (saved != null && saved.trim().isNotEmpty) ? saved.trim() : '';

    return dioFactory.build(
      baseUrl: baseUrl,
      sharedPreferences: sharedPreferences,
      tokenStorage: tokenStorage,
    );
  }

  @lazySingleton
  FlutterSecureStorage secureStorage() => const FlutterSecureStorage();

  @lazySingleton
  TokenStorage tokenStorage(FlutterSecureStorage secureStorage) {
    return SecureTokenStorage(secureStorage);
  }
}

@injectable
class DioFactory {
  Dio build({
    required String baseUrl,
    required SharedPreferences sharedPreferences,
    required TokenStorage tokenStorage,
  }) {
    final bool isWebAuth = sharedPreferences.getBool(SharedPrefsKeys.isWebAuth) ?? false;
    final String basePath = (isWebAuth && kIsWeb) ? "/json" : "/api/v1";

    final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl.isEmpty ? 'http://placeholder.local' : '$baseUrl$basePath',
        receiveTimeout: const Duration(seconds: 90),
      ),
    );

    final adapter = createPlatformAdapter();
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
    }

    dio.interceptors
      ..add(BaseUrlInterceptor(sharedPreferences))
      ..add(TokenInterceptor(tokenStorage))
      ..add(SessionIdInterceptor(tokenStorage))
      ..add(CsrfCookieInterceptor(tokenStorage))
      ..add(EnumInterceptor());

    return dio;
  }
}
