import 'package:genesis_workspace/data/messages/dto/delete_message_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class DeleteMessageResponseEntity extends ResponseEntity {
  DeleteMessageResponseEntity({required super.msg, required super.result});
}

class DeleteMessageRequestEntity {
  final int messageId;
  DeleteMessageRequestEntity({required this.messageId});

  DeleteMessageRequestDto toDto() {
    return DeleteMessageRequestDto(messageId: messageId);
  }
}
