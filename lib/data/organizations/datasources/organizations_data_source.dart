import 'package:dio/dio.dart';
import 'package:genesis_workspace/features/authentication/data/dto/server_settings_response_dto.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrganizationsDataSource {
  final Dio _dio = Dio();

  Future<ServerSettingsResponseDto> getOrganizationSettings(String url) async {
    try {
      final response = await _dio.get('$url/api/v1/server_settings');
      final serverSettings = ServerSettingsResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      return serverSettings;
    } catch (e) {
      rethrow;
    }
  }
}
