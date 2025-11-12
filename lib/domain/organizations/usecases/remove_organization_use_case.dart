import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RemoveOrganizationUseCase {
  final OrganizationsRepository _repository;
  RemoveOrganizationUseCase(this._repository);

  Future<void> call(int organizationId) async {
    await _repository.removeOrganization(organizationId);
  }
}
