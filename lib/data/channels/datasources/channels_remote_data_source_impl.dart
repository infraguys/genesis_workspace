import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/channels/api/channels_api_client.dart';
import 'package:genesis_workspace/data/channels/datasources/channels_data_source.dart';
import 'package:genesis_workspace/data/channels/dto/channel_dto.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ChannelsDataSource)
class ChannelsRemoteDataSourceImpl implements ChannelsDataSource {
  final ChannelsApiClient _apiClient = ChannelsApiClient(getIt<Dio>());

  @override
  Future<CreateChannelResponseDto> createChannel(CreateChannelRequestDto body) async {
    return await _apiClient.createChannel(
      body.name,
      jsonEncode(body.subscribers),
    );
  }
}
