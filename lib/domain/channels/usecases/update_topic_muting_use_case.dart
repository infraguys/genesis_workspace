import 'package:genesis_workspace/domain/channels/entities/update_topic_muting_entity.dart';
import 'package:genesis_workspace/domain/channels/repositories/channels_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateTopicMutingUseCase {
  final ChannelsRepository _repository;
  UpdateTopicMutingUseCase(this._repository);

  Future<void> call(UpdateTopicMutingRequestEntity body) async {
    try {
      return await _repository.updateTopicMuting(body);
    } catch (e) {
      rethrow;
    }
  }
}
