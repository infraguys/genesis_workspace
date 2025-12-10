import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/common/dto/version_config_dto.dart';
import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVersionConfigUseCase {
  final Dio _dio = Dio();

  Future<VersionConfigEntity> call() async {
    try {
      final Response<List<int>> response = await _dio.get<List<int>>(
        AppConstants.versionConfigUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final List<int> rawBytes = response.data!;
      final String sha256Hash = sha256.convert(rawBytes).toString();

      // Для парсинга JSON:
      final String jsonString = utf8.decode(rawBytes);
      final dynamic jsonData = jsonDecode(jsonString);

      final VersionConfigDto dto = VersionConfigDto.fromJson(jsonData);
      final VersionConfigEntity entity = dto.toEntity().copyWith(
        sha256: sha256Hash,
      );

      return entity;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        inspect(error);
        inspect(stackTrace);
      }
      rethrow;
    }
  }
}
