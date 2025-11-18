import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class DownloadFilesService {
  DownloadFilesService(this._dio, this._sharedPreferences);

  final Dio _dio;
  final SharedPreferences _sharedPreferences;

  /// Делает авторизованный GET к файловому пути (`/user_uploads/...`) без подстановки `/api/v1`.
  Future<Response<Uint8List>> download(
    String pathToFile, {
    ProgressCallback? onReceiveProgress,
  }) async {
    final String? savedBaseUrl = _sharedPreferences.getString(SharedPrefsKeys.baseUrl);
    if (savedBaseUrl == null || savedBaseUrl.trim().isEmpty) {
      throw StateError('Base URL is not set.');
    }

    final String normalizedBase = savedBaseUrl.trim();
    final String normalizedPath = pathToFile.startsWith('/') ? pathToFile : '/$pathToFile';
    final Uri targetUri = Uri.parse('$normalizedBase$normalizedPath');

    return _dio.getUri<Uint8List>(
      targetUri,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        extra: const {'skipBaseUrlInterceptor': true},
        validateStatus: (status) => status != null && status < 400,
      ),
    );
  }
}
