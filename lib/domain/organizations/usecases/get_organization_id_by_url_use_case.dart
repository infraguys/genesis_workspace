import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrganizationIdByUrlUseCase {
  final OrganizationsRepository _repository;

  GetOrganizationIdByUrlUseCase(this._repository);

  Future<int?> call(String url) {
    return _repository.getOrganizationIdByComparableUrl(url);
  }
}
