import 'package:genesis_workspace/domain/drafts/entities/create_drafts_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/edit_draft_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/get_drafts_entity.dart';

abstract class DraftsRepository {
  Future<GetDraftsResponseEntity> getDrafts();
  Future<CreateDraftsResponseEntity> createDrafts(CreateDraftsRequestEntity body);
  Future<void> deleteDraft(int id);
  Future<void> editDraft(EditDraftRequestEntity body);
}
