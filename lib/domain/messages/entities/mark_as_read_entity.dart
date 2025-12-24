import 'package:genesis_workspace/data/messages/dto/mark_as_read_dto.dart';

class MarkStreamAsReadRequestEntity {
  final int streamId;
  MarkStreamAsReadRequestEntity({required this.streamId});

  MarkStreamAsReadRequestDto toDto() => MarkStreamAsReadRequestDto(streamId: streamId);
}

class MarkTopicAsReadRequestEntity {
  final int streamId;
  final String topicName;
  MarkTopicAsReadRequestEntity({required this.streamId, required this.topicName});

  MarkTopicAsReadRequestDto toDto() => MarkTopicAsReadRequestDto(streamId: streamId, topicName: topicName);
}
