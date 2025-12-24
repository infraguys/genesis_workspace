class MarkStreamAsReadRequestDto {
  final int streamId;
  MarkStreamAsReadRequestDto({required this.streamId});
}

class MarkTopicAsReadRequestDto {
  final int streamId;
  final String topicName;
  MarkTopicAsReadRequestDto({required this.streamId, required this.topicName});
}
