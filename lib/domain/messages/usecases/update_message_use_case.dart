import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMessageUseCase {
  final MessagesRepository _repository;

  UpdateMessageUseCase(this._repository);

  Future<UpdateMessageResponseEntity> call(UpdateMessageRequestEntity body) async {
    return await _repository.updateMessage(body);
  }
}
