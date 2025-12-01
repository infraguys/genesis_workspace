import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrganizationSettingsUseCase {
  final OrganizationsRepository _repository;
  GetOrganizationSettingsUseCase(this._repository);

  Future<ServerSettingsEntity> call(String url) async {
    try {
      return await _repository.getOrganizationSettings(url);
    } catch (e) {
      rethrow;
    }
  }
}
