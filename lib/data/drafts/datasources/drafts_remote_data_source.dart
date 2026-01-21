import 'package:genesis_workspace/data/drafts/dto/create_drafts_dto.dart';
import 'package:genesis_workspace/data/drafts/dto/get_drafts_dto.dart';

abstract class DraftsRemoteDataSource {
  Future<GetDraftsResponseDto> getDrafts();
  Future<CreateDraftsResponseDto> createDrafts(CreateDraftsRequestDto body);
  Future<void> editDraft();
  Future<void> deleteDraft(int id);
}
