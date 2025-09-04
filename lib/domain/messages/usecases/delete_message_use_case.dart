import 'package:genesis_workspace/domain/messages/entities/delete_message_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteMessageUseCase {
  final MessagesRepository _repository;
  DeleteMessageUseCase(this._repository);

  Future<DeleteMessageResponseEntity> call(DeleteMessageRequestEntity body) async {
    try {
      return await _repository.deleteMessage(body);
    } catch (e) {
      rethrow;
    }
  }
}
