import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/data/users/dto/presence_dto.dart';
import 'package:genesis_workspace/domain/users/entities/user_presence_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_presence_dto.g.dart';

@JsonSerializable()
class UserPresenceResponseDto extends ResponseDto {
  UserPresenceResponseDto({required super.msg, required super.result, required this.presence});
  final PresenceDto presence;

  factory UserPresenceResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserPresenceResponseDtoFromJson(json);

  UserPresenceResponseEntity toEntity() =>
      UserPresenceResponseEntity(userPresence: presence.toEntity(), msg: msg, result: result);
}

class UserPresenceRequestDto {
  final int userId;
  UserPresenceRequestDto({required this.userId});

  Map<String, dynamic> toJson() => {'user_id_or_email': userId.toString()};
}
