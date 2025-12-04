import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';

@injectable
class DeleteFolderUseCase {
  final FolderRepository _repository;
  DeleteFolderUseCase(this._repository);

  Future<void> call(DeleteFolderEntity folder) async {
    await _repository.deleteFolder(folder);
  }
}
