import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/domain/genesis/repositories/genesis_services_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetServiceByIdUseCase {
  final GenesisServicesRepository _repository;
  GetServiceByIdUseCase(this._repository);

  Future<GenesisServiceEntity> call(GenesisServiceRequestEntity body) async {
    try {
      return await _repository.getServiceById(body);
    } catch (e) {
      rethrow;
    }
  }
}
