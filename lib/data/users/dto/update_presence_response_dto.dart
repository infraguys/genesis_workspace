import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_presence_response_dto.g.dart';

@JsonSerializable()
class UpdatePresenceResponseDto extends ResponseDto {
  @JsonKey(name: 'presence_last_update_id')
  final int? presenceLastUpdateId;

  UpdatePresenceResponseDto({required super.msg, required super.result, this.presenceLastUpdateId});

  factory UpdatePresenceResponseDto.fromJson(Map<String, dynamic> json) => _$UpdatePresenceResponseDtoFromJson(json);

  UpdatePresenceResponseEntity toEntity() => UpdatePresenceResponseEntity(
    msg: msg,
    result: result,
    presenceLastUpdateId: presenceLastUpdateId,
  );
}
