import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';

@injectable
class GetFoldersUseCase {
  final FolderRepository _repository;
  GetFoldersUseCase(this._repository);

  Future<List<FolderItemEntity>> call() async {
    return _repository.getFolders();
  }
}

