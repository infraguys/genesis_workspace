import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMessagesFlagsUseCase {
  final MessagesRepository _repository;
  UpdateMessagesFlagsUseCase(this._repository);

  Future<void> call(UpdateMessagesFlagsRequestEntity body) async {
    try {
      await _repository.updateMessagesFlags(body);
    } catch (e) {
      rethrow;
    }
  }
}
