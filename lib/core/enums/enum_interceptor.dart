// auth_interceptor.dart
import 'package:dio/dio.dart';

class EnumInterceptor extends Interceptor {
  EnumInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.queryParameters.updateAll((k, v) {
      if (v is Enum) return v.name;
      return v;
    });
    handler.next(options);
  }
}
