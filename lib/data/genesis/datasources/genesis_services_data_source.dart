import 'package:genesis_workspace/data/genesis/dto/genesis_service_dto.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';

abstract class GenesisServicesDataSource {
  Future<List<GenesisServiceEntity>> getServices();

  Future<GenesisServiceEntity> getServiceByUUID(GenesisServiceRequestDto body);
}
