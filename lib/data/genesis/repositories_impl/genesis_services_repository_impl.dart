import 'package:genesis_workspace/data/genesis/datasources/genesis_services_data_source.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/domain/genesis/repositories/genesis_services_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: GenesisServicesRepository)
class GenesisServicesRepositoryImpl implements GenesisServicesRepository {
  final GenesisServicesDataSource _dataSource;

  GenesisServicesRepositoryImpl(this._dataSource);

  @override
  Future<GenesisServiceEntity> getServiceById(GenesisServiceRequestEntity body) async {
    try {
      final service = await _dataSource.getServiceByUUID(body.toDto());
      return service;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GenesisServiceEntity>> getServices() async {
    try {
      return await _dataSource.getServices();
    } catch (e) {
      rethrow;
    }
  }
}
