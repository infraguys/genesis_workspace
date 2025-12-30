import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';

abstract class GenesisServicesRepository {
  Future<List<GenesisServiceEntity>> getServices();
  Future<GenesisServiceEntity> getServiceById(GenesisServiceRequestEntity body);
}
