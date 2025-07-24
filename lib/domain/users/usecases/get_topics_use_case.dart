import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTopicsUseCase {
  final UsersRepository _repository;
  GetTopicsUseCase(this._repository);

  Future<List<TopicEntity>> call(int streamId) async {
    try {
      return await _repository.getChannelTopics(streamId);
    } catch (e) {
      rethrow;
    }
  }
}
