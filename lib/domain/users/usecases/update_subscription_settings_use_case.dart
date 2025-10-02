import 'package:genesis_workspace/domain/users/entities/update_subscription_settings_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateSubscriptionSettingsUseCase {
  final UsersRepository _repository;

  UpdateSubscriptionSettingsUseCase(this._repository);

  Future<UpdateSubscriptionResponseEntity> call(UpdateSubscriptionRequestEntity body) async {
    return await _repository.updateSubscriptionSettings(body);
  }
}
