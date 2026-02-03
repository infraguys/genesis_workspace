import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/delete_message_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delete_message_dto.g.dart';

@JsonSerializable()
class DeleteMessageResponseDto extends ResponseDto {
  DeleteMessageResponseDto({required super.msg, required super.result});

  factory DeleteMessageResponseDto.fromJson(Map<String, dynamic> json) => _$DeleteMessageResponseDtoFromJson(json);

  DeleteMessageResponseEntity toEntity() => DeleteMessageResponseEntity(msg: msg, result: result);
}

class DeleteMessageRequestDto {
  final int messageId;
  DeleteMessageRequestDto({required this.messageId});
}
