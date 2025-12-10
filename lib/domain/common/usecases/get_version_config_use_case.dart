import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/common/dto/version_config_dto.dart';
import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVersionConfigUseCase {
  final Dio _dio = Dio();

  Future<VersionConfigEntity> call() async {
    try {
      final response = await _dio.get(AppConstants.versionConfigUrl);
      final responseData = response.data;

      final String jsonString = jsonEncode(responseData);
      final List<int> utf8Bytes = utf8.encode(jsonString);
      final Digest sha256Digest = sha256.convert(utf8Bytes);

      final String sha256Hash = sha256Digest.toString();

      final VersionConfigDto dto = VersionConfigDto.fromJson(responseData);
      final VersionConfigEntity entity = dto.toEntity();

      return entity.copyWith(
        sha256: sha256Hash,
      );
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }
}
