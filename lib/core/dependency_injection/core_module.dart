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
import 'package:genesis_workspace/services/token_storage/file_token_storage.dart';
import 'package:genesis_workspace/services/token_storage/secure_token_storage.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class CoreModule {
  @lazySingleton
  AppDatabase appDatabase() => AppDatabase();

  @preResolve
  @lazySingleton
  Future<Dio> dio(TokenStorage tokenStorage) async {
    final prefs = await SharedPreferences.getInstance();
    final isWebAuth = prefs.getBool(SharedPrefsKeys.isWebAuth) ?? false;

    final basePath = (isWebAuth && kIsWeb) ? "/json" : "/api/v1";
    final dio = Dio(
      BaseOptions(
        baseUrl: "${AppConstants.baseUrl}$basePath",
        receiveTimeout: Duration(seconds: 90),
      ),
    );

    final adapter = createPlatformAdapter();
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
    }

    dio.interceptors
      ..add(BaseUrlInterceptor(prefs))
      ..add(TokenInterceptor(tokenStorage))
      ..add(SessionidInterceptor(tokenStorage))
      ..add(CsrfCookieInterceptor(tokenStorage))
      ..add(EnumInterceptor());
    return dio;
  }

  @lazySingleton
  FlutterSecureStorage secureStorage() => const FlutterSecureStorage();

  @lazySingleton
  TokenStorage tokenStorage(FlutterSecureStorage secureStorage) {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        kIsWeb) {
      return SecureTokenStorage(secureStorage);
    } else {
      return FileTokenStorage();
    }
  }
}
