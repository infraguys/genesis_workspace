import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/channels/repositories/channels_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateChannelUseCase {
  final ChannelsRepository _repository;
  CreateChannelUseCase(this._repository);

  Future<CreateChannelResponseEntity> call(CreateChannelRequestEntity body) async {
    return await _repository.createChannel(body);
  }
}
