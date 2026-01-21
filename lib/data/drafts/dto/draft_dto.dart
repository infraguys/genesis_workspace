import 'package:genesis_workspace/core/enums/draft_type.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'draft_dto.g.dart';

@JsonSerializable()
class DraftDto {
  @JsonKey(includeToJson: false)
  final int? id;
  final DraftType type;
  final List<int> to;
  final String topic;
  final String content;
  @JsonKey(includeToJson: false)
  final int? timestamp;

  DraftDto({
    this.id,
    required this.type,
    required this.to,
    required this.topic,
    required this.content,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => _$DraftDtoToJson(this);

  factory DraftDto.fromJson(Map<String, dynamic> json) => _$DraftDtoFromJson(json);

  DraftEntity toEntity() => DraftEntity(
    id: id,
    type: type,
    to: to,
    topic: topic,
    content: content,
    chatId: -1,
  );
}
