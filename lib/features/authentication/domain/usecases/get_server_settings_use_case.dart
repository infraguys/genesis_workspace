import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetServerSettingsUseCase {
  final AuthRepository _repository;

  GetServerSettingsUseCase(this._repository);

  Future<ServerSettingsEntity> call() async {
    try {
      return await _repository.getServerSettings();
    } catch (e) {
      rethrow;
    }
  }
}
