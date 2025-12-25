import 'package:genesis_workspace/domain/messages/entities/mark_as_read_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class MarkStreamAsReadUseCase {
  final MessagesRepository _repository;
  MarkStreamAsReadUseCase(this._repository);

  Future<void> call(MarkStreamAsReadRequestEntity body) async {
    try {
      await _repository.markStreamAsRead(body);
    } catch (e) {
      rethrow;
    }
  }
}
