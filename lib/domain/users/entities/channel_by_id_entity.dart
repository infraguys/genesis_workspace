import 'package:genesis_workspace/data/users/dto/channel_by_id_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';
import 'package:genesis_workspace/domain/users/entities/stream_entity.dart';

class ChannelByIdResponseEntity extends ResponseEntity {
  final StreamEntity stream;
  ChannelByIdResponseEntity({required super.msg, required super.result, required this.stream});
}

class ChannelByIdRequestEntity {
  final int streamId;
  ChannelByIdRequestEntity({required this.streamId});

  ChannelByIdRequestDto toDto() => ChannelByIdRequestDto(streamId: streamId);
}
