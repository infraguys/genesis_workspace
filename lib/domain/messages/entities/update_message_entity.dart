import 'package:genesis_workspace/data/messages/dto/update_message_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class UpdateMessageResponseEntity extends ResponseEntity {
  UpdateMessageResponseEntity({
    required super.msg,
    required super.result,
  });
}

class UpdateMessageRequestEntity {
  UpdateMessageRequestEntity({
    required this.messageId,
    this.content,
    this.topic,
    this.propagateMode,
  });

  final int messageId;
  final String? content;
  final String? topic;
  final String? propagateMode;

  UpdateMessageRequestDto toDto() => UpdateMessageRequestDto(
    messageId: messageId,
    content: content,
    topic: topic,
    propagateMode: propagateMode,
  );
}
