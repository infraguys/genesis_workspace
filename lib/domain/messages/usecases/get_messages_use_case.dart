import 'package:genesis_workspace/domain/common/mixins/mock_error_use_case.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMessagesUseCase with MockErrorUseCase {
  final MessagesRepository _repository;

  GetMessagesUseCase(this._repository);

  Future<MessagesResponseEntity> call(MessagesRequestEntity body, {bool mockError = false}) async {
    throwIfMockError(mockError: mockError);
    try {
      return await _repository.getMessages(body);
    } catch (e) {
      rethrow;
    }
  }
}
