import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddFolderUseCase {
  final FolderRepository _repository;
  AddFolderUseCase(this._repository);

  Future<void> call(CreateFolderEntity folder) async {
    await _repository.addFolder(folder);
  }
}
