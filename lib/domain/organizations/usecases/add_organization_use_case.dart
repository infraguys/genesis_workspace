import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddOrganizationUseCase {
  final OrganizationsRepository _repository;
  AddOrganizationUseCase(this._repository);

  Future<int> call(OrganizationRequestEntity body) async {
    return await _repository.addOrganization(body);
  }
}
