import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/genesis/api/genesis_api_client.dart';
import 'package:genesis_workspace/data/genesis/datasources/genesis_services_data_source.dart';
import 'package:genesis_workspace/data/genesis/dto/genesis_service_dto.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: GenesisServicesDataSource)
class GenesisServicesDataSourceImpl implements GenesisServicesDataSource {
  GenesisServicesDataSourceImpl();

  GenesisApiClient? _apiClient;
  String? _cachedBaseUrl;

  GenesisApiClient get _client {
    final currentBaseUrl = AppConstants.baseUrl;
    if (_apiClient == null || _cachedBaseUrl != currentBaseUrl) {
      _cachedBaseUrl = currentBaseUrl;
      _apiClient = GenesisApiClient(
        getIt<Dio>(),
        baseUrl: "$currentBaseUrl/workspace/v1/",
      );
    }
    return _apiClient!;
  }

  @override
  Future<List<GenesisServiceEntity>> getServices() async {
    try {
      final services = await _client.getServices();
      return services.map((service) => service.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GenesisServiceEntity> getServiceByUUID(GenesisServiceRequestDto body) async {
    try {
      final service = await _client.getServiceById(body.uuid);
      return service.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
