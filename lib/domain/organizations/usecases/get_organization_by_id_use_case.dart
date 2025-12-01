import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrganizationByIdUseCase {
  final OrganizationsRepository _repository;

  GetOrganizationByIdUseCase(this._repository);

  Future<OrganizationEntity> call(int id) async {
    return await _repository.getOrganizationById(id);
  }
}
