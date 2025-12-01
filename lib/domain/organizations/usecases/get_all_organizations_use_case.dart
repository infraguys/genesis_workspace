import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllOrganizationsUseCase {
  final OrganizationsRepository _repository;
  GetAllOrganizationsUseCase(this._repository);

  Future<List<OrganizationEntity>> call() async {
    return await _repository.getAllOrganizations();
  }
}
