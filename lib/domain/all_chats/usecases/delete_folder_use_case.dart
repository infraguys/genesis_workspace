import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';

@injectable
class DeleteFolderUseCase {
  final FolderRepository _repository;
  DeleteFolderUseCase(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteFolder(id);
  }
}

