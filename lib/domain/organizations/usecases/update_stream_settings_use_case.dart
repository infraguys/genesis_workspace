import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateStreamSettingsUseCase {
  UpdateStreamSettingsUseCase(this._repository);

  final OrganizationsRepository _repository;

  Future<void> call({
    required int organizationId,
    int? maxNameLength,
    int? maxDescriptionLength,
  }) {
    return _repository.updateStreamSettings(
      organizationId: organizationId,
      maxNameLength: maxNameLength,
      maxDescriptionLength: maxDescriptionLength,
    );
  }
}
