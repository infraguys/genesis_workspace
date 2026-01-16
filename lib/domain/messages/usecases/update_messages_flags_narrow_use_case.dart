import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMessagesFlagsNarrowUseCase {
  final MessagesRepository _repository;
  UpdateMessagesFlagsNarrowUseCase(this._repository);

  Future<UpdateMessagesFlagsNarrowResponseEntity> call(UpdateMessagesFlagsNarrowRequestEntity body) async {
    try {
      final response = await _repository.updateMessagesFlagsNarrow(body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
