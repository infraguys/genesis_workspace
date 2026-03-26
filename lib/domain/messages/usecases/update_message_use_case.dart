import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMessageUseCase {
  UpdateMessageUseCase(this._repository);

  final MessagesRepository _repository;

  Future<UpdateMessageResponseEntity> call(UpdateMessageRequestEntity body) async {
    return await _repository.updateMessage(body);
  }
}
