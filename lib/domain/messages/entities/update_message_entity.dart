import 'package:genesis_workspace/data/messages/dto/update_message_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class UpdateMessageResponseEntity extends ResponseEntity {
  UpdateMessageResponseEntity({required super.msg, required super.result});
}

class UpdateMessageRequestEntity {
  final int messageId;
  final String content;
  UpdateMessageRequestEntity({required this.messageId, required this.content});

  UpdateMessageRequestDto toDto() =>
      UpdateMessageRequestDto(messageId: messageId, content: content);
}

