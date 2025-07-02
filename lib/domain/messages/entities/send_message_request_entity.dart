import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/data/messages/dto/send_message_request_dto.dart';

class SendMessageRequestEntity {
  final SendMessageType type;
  final List<int> to;
  final String content;

  SendMessageRequestEntity({required this.type, required this.to, required this.content});

  SendMessageRequestDto toDto() => SendMessageRequestDto(type: type, to: to, content: content);
}
