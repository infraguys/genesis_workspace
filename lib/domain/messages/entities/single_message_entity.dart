import 'package:genesis_workspace/data/messages/dto/single_message_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';

class SingleMessageResponseEntity extends ResponseEntity {
  SingleMessageResponseEntity({required super.msg, required super.result, required this.message});
  final MessageEntity message;
}

class SingleMessageRequestEntity {
  final int messageId;
  final bool applyMarkdown;

  SingleMessageRequestEntity({required this.messageId, required this.applyMarkdown});

  SingleMessageRequestDto toDto() =>
      SingleMessageRequestDto(messageId: messageId, applyMarkdown: applyMarkdown);
}
