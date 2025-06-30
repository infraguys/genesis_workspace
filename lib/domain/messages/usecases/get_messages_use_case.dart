import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMessagesUseCase {
  final MessagesRepository _repository = getIt<MessagesRepository>();

  Future<MessagesResponseEntity> call(MessagesRequestEntity body) async {
    try {
      return await _repository.getMessages(body);
    } catch (e) {
      rethrow;
    }
  }
}
