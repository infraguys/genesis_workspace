import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/message_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/single_message_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'single_message_dto.g.dart';

@JsonSerializable()
class SingleMessageResponseDto extends ResponseDto {
  SingleMessageResponseDto({
    required super.msg,
    required super.result,
    required this.message,
  });
  final MessageDto message;

  factory SingleMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SingleMessageResponseDtoFromJson(json);

  SingleMessageResponseEntity toEntity() => SingleMessageResponseEntity(
    msg: msg,
    result: result,
    message: message.toEntity(),
  );
}

class SingleMessageRequestDto {
  final int messageId;
  final bool applyMarkdown;

  SingleMessageRequestDto({required this.messageId, required this.applyMarkdown});
}
