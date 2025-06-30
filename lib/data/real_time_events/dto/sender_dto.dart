import 'package:genesis_workspace/domain/real_time_events/entities/sender_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sender_dto.g.dart';

@JsonSerializable()
class SenderDto {
  @JsonKey(name: 'user_id')
  final int userId;

  final String email;

  SenderDto({required this.userId, required this.email});

  factory SenderDto.fromJson(Map<String, dynamic> json) => _$SenderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SenderDtoToJson(this);

  SenderEntity toEntity() => SenderEntity(userId: userId, email: email);
}
