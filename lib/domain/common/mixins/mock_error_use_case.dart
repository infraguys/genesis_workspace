import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

mixin MockErrorUseCase {
  void throwIfMockError({required bool mockError}) {
    if (!kDebugMode || !mockError) return;

    const String path = 'mock-request';
    final requestOptions = RequestOptions(path: path);

    throw DioException.badResponse(
      statusCode: 400,
      requestOptions: requestOptions,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 400,
        statusMessage: 'Mock error',
        data: 'Mock error',
      ),
    );
  }
}
