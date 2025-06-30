import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_recipient_dto.g.dart';

@JsonSerializable()
class MessageRecipientDto {
  final String email;
  @JsonKey(name: 'full_name')
  final String fullName;
  final int id;

  MessageRecipientDto({required this.email, required this.id, required this.fullName});

  factory MessageRecipientDto.fromJson(Map<String, dynamic> json) =>
      _$MessageRecipientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageRecipientDtoToJson(this);

  RecipientEntity toEntity() => RecipientEntity(email: email, userId: id);
}
