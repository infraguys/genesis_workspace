import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/domain/genesis/repositories/genesis_services_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetServicesUseCase {
  final GenesisServicesRepository _repository;
  GetServicesUseCase(this._repository);

  Future<List<GenesisServiceEntity>> call() async {
    try {
      return await _repository.getServices();
    } catch (e) {
      rethrow;
    }
  }
}
