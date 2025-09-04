import 'package:genesis_workspace/domain/messages/entities/single_message_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMessageByIdUseCase {
  final MessagesRepository _repository;

  GetMessageByIdUseCase(this._repository);

  Future<SingleMessageResponseEntity> call(SingleMessageRequestEntity body) async {
    try {
      return await _repository.getMessageById(body);
    } catch (e) {
      rethrow;
    }
  }
}
