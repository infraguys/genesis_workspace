import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'typing_request_dto.g.dart';

@JsonSerializable()
class TypingRequestDto {
  TypingRequestDto({
    required this.type,
    required this.op,
    this.to,
    this.streamId,
    this.topic,
  });

  @JsonKey(name: 'type')
  final SendMessageType type;
  @JsonKey(name: 'op')
  final TypingEventOp op;
  @JsonKey(name: 'to')
  @ToListAsJsonStringConverter()
  final List<int>? to;
  @JsonKey(name: 'stream_id')
  final int? streamId;
  @JsonKey(name: 'topic')
  final String? topic;

  Map<String, dynamic> toJson() => _$TypingRequestDtoToJson(this);
}
