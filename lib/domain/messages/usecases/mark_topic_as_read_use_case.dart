import 'package:genesis_workspace/domain/messages/entities/mark_as_read_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class MarkTopicAsReadUseCase {
  final MessagesRepository _repository;
  MarkTopicAsReadUseCase(this._repository);

  Future<void> call(MarkTopicAsReadRequestEntity body) async {
    try {
      await _repository.markTopicAsRead(body);
    } catch (e) {
      rethrow;
    }
  }
}
