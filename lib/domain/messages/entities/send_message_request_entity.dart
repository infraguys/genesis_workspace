import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/data/messages/dto/send_message_request_dto.dart';

class SendMessageRequestEntity {
  final SendMessageType type;
  final Object to;
  final String content;
  final String? topic;
  final int? streamId;

  SendMessageRequestEntity({
    required this.type,
    required this.to,
    required this.content,
    this.topic,
    this.streamId,
  });

  SendMessageRequestDto toDto() =>
      SendMessageRequestDto(type: type, to: to, content: content, topic: topic, streamId: streamId);

  String? get toAsString => to is String ? to as String : null;
  int? get toAsInt => to is int ? to as int : null;
  List<String>? get toAsStringList => to is List<String> ? to as List<String> : null;
  List<int>? get toAsIntList => to is List<int> ? to as List<int> : null;
}
