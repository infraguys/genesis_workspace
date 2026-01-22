import 'package:genesis_workspace/data/drafts/dto/edit_draft_dto.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';

class EditDraftRequestEntity {
  final int id;
  final DraftEntity draft;
  EditDraftRequestEntity({required this.id, required this.draft});

  EditDraftRequestDto toDto() => EditDraftRequestDto(id: id, draft: draft.toDto());
}
