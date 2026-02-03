import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipient_dto.g.dart';

@JsonSerializable()
class RecipientDto {
  final String email;
  final int userId;
  @JsonKey(name: 'full_name')
  final String? fullName;

  RecipientDto({required this.email, required this.userId, required this.fullName});

  factory RecipientDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['user_id'] ?? -1;
    return RecipientDto(email: json['email'], userId: id, fullName: json['full_name']);
  }

  Map<String, dynamic> toJson() => _$RecipientDtoToJson(this);

  RecipientEntity toEntity() => RecipientEntity(email: email, userId: userId, fullName: fullName ?? '');
}
