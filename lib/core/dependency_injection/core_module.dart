import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/enum_interceptor.dart';
import 'package:genesis_workspace/services/token_storage/token_interceptor.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@module
abstract class CoreModule {
  @lazySingleton
  Dio dio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "${AppConstants.baseUrl}/api/v1",
        // connectTimeout: const Duration(seconds: 10),
        // receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final tokenStorage = TokenStorageFactory.create();
    dio.interceptors
      ..add(TokenInterceptor(tokenStorage))
      ..add(EnumInterceptor());
    return dio;
  }

  @lazySingleton
  FlutterSecureStorage secureStorage() => FlutterSecureStorage();
}
