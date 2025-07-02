import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_message_request_dto.g.dart';

@JsonSerializable()
class SendMessageRequestDto {
  final SendMessageType type;
  @ToListAsJsonStringConverter()
  final List<int> to;
  final String content;

  SendMessageRequestDto({required this.type, required this.to, required this.content});

  Map<String, dynamic> toJson() => _$SendMessageRequestDtoToJson(this);
}
