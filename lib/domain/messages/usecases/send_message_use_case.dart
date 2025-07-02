import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendMessageUseCase {
  final MessagesRepository _repository;
  SendMessageUseCase(this._repository);

  Future<void> call(SendMessageRequestEntity body) async {
    try {
      await _repository.sendMessage(body);
    } catch (e) {
      rethrow;
    }
  }
}
