import 'package:genesis_workspace/domain/drafts/repositories/drafts_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteDraftUseCase {
  final DraftsRepository _repository;
  DeleteDraftUseCase(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteDraft(id);
  }
}
