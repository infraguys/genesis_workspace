import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';

class UpdateMessageResponseDto extends ResponseDto {
  UpdateMessageResponseDto({required super.msg, required super.result});

  factory UpdateMessageResponseDto.fromJson(Map<String, dynamic> json) => UpdateMessageResponseDto(
    msg: (json['msg'] as String?) ?? '',
    result: (json['result'] as String?) ?? 'success',
  );

  UpdateMessageResponseEntity toEntity() => UpdateMessageResponseEntity(msg: msg, result: result);
}

class UpdateMessageRequestDto {
  final int messageId;
  final String content;
  UpdateMessageRequestDto({required this.messageId, required this.content});
}
