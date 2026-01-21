import 'package:genesis_workspace/data/drafts/dto/draft_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'edit_draft_dto.g.dart';

@JsonSerializable()
class EditDraftRequestDto {
  final int id;
  final DraftDto draft;
  EditDraftRequestDto({required this.id, required this.draft});

  Map<String, dynamic> toJson() => _$EditDraftRequestDtoToJson(this);
}
