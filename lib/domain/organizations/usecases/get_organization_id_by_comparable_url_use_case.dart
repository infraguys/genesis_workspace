import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';

class GetOrganizationIdByComparableUrlUseCase {
  final OrganizationsRepository _repository;

  GetOrganizationIdByComparableUrlUseCase(this._repository);

  Future<int?> call(String url) {
    return _repository.getOrganizationIdByComparableUrl(url);
  }
}
