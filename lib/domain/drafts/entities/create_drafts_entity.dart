import 'package:genesis_workspace/data/drafts/dto/create_drafts_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';

class CreateDraftsResponseEntity extends ResponseEntity {
  final List<int> ids;
  CreateDraftsResponseEntity({required super.msg, required super.result, required this.ids});
}

class CreateDraftsRequestEntity {
  final List<DraftEntity> drafts;

  CreateDraftsRequestEntity({required this.drafts});

  CreateDraftsRequestDto toDto() => CreateDraftsRequestDto(
    drafts: drafts.map((draft) => draft.toDto()).toList(),
  );
}
