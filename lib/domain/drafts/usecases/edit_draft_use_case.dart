import 'package:genesis_workspace/domain/drafts/entities/edit_draft_entity.dart';
import 'package:genesis_workspace/domain/drafts/repositories/drafts_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class EditDraftUseCase {
  final DraftsRepository _repository;
  EditDraftUseCase(this._repository);

  Future<void> call(EditDraftRequestEntity body) async {
    return await _repository.editDraft(body);
  }
}
