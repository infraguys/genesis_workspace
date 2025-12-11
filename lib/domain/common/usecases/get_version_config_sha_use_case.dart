import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVersionConfigShaUseCase {
  final Dio _dio = Dio();

  Future<String> call() async {
    try {
      final response = await _dio.get(AppConstants.versionConfigShaUrl);
      return response.data;
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }
}
