import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/common/dto/version_config_dto.dart';
import 'package:genesis_workspace/domain/common/entities/version_config_entity.dart';

class GetVersionConfigUseCase {
  final Dio _dio = Dio();

  Future<VersionConfigEntity> call() async {
    try {
      final response = await _dio.get(AppConstants.versionConfigUrl);
      final dto = VersionConfigDto.fromJson(response.data);
      final entity = dto.toEntity();
      return entity;
    } catch (e) {
      rethrow;
    }
  }
}
