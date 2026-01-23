import 'package:genesis_workspace/data/channels/datasources/channels_data_source.dart';
import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/channels/repositories/channels_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ChannelsRepository)
class ChannelsRepositoryImpl implements ChannelsRepository {
  final ChannelsDataSource _dataSource;
  ChannelsRepositoryImpl(this._dataSource);
  @override
  Future<void> createChannel(CreateChannelRequestEntity body) async {
    return await _dataSource.createChannel(body.toDto());
  }
}
