import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';

@injectable
class AddFolderUseCase {
  final FolderRepository _repository;
  AddFolderUseCase(this._repository);

  Future<void> call(FolderItemEntity folder) async {
    await _repository.addFolder(folder);
  }
}

