import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipient_dto.g.dart';

@JsonSerializable()
class RecipientDto {
  final String email;
  @JsonKey(name: 'user_id')
  final int userId;

  RecipientDto({required this.email, required this.userId});

  factory RecipientDto.fromJson(Map<String, dynamic> json) => _$RecipientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecipientDtoToJson(this);

  RecipientEntity toEntity() => RecipientEntity(email: email, userId: userId);
}
