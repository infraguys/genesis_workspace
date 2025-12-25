import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMessageReadersUseCase {
  GetMessageReadersUseCase(this._repository);

  final MessagesRepository _repository;

  Future<List<UserEntity>> call(int messageId) async {
    try {
      return await _repository.getMessageReaders(messageId);
    } catch (e) {
      rethrow;
    }
  }
}
