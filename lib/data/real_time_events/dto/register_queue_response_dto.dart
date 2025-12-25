import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_queue_response_dto.g.dart';

@JsonSerializable()
class RegisterQueueResponseDto {
  @JsonKey(name: "queue_id")
  final String queueId;
  final String msg;
  final String result;
  @JsonKey(name: "last_event_id")
  final int lastEventId;
  @JsonKey(name: "realm_jitsi_server_url")
  final String? realmJitsiServerUrl;

  RegisterQueueResponseDto({
    required this.queueId,
    required this.msg,
    required this.result,
    required this.lastEventId,
    this.realmJitsiServerUrl,
  });

  factory RegisterQueueResponseDto.fromJson(Map<String, dynamic> json) => _$RegisterQueueResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterQueueResponseDtoToJson(this);

  RegisterQueueEntity toEntity() => RegisterQueueEntity(
    queueId: queueId,
    msg: msg,
    result: result,
    lastEventId: lastEventId,
    realmJitsiServerUrl: realmJitsiServerUrl,
  );
}
