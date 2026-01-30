import 'package:genesis_workspace/data/channels/datasources/channels_data_source.dart';
import 'package:genesis_workspace/data/common/dto/exception_dto.dart';
import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/channels/entities/update_topic_muting_entity.dart';
import 'package:genesis_workspace/domain/channels/repositories/channels_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ChannelsRepository)
class ChannelsRepositoryImpl implements ChannelsRepository {
  final ChannelsDataSource _dataSource;
  ChannelsRepositoryImpl(this._dataSource);
  @override
  Future<CreateChannelResponseEntity> createChannel(CreateChannelRequestEntity body) async {
    try {
      final response = await _dataSource.createChannel(body.toDto());
      return response.toEntity();
    } on ServerExceptionDto catch (e) {
      throw e.toEntity();
    }
  }

  @override
  Future<void> updateTopicMuting(UpdateTopicMutingRequestEntity body) async {
    try {
      return await _dataSource.updateTopicMuting(body.toDto());
    } catch (e) {
      rethrow;
    }
  }
}
