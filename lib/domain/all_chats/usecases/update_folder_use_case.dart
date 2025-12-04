import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateFolderUseCase {
  final FolderRepository _repository;
  UpdateFolderUseCase(this._repository);

  Future<FolderEntity> call(UpdateFolderEntity folder) async {
    return await _repository.updateFolder(folder);
  }
}
