import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetFoldersUseCase {
  final FolderRepository _repository;

  GetFoldersUseCase(this._repository);

  Future<List<FolderEntity>> call(int organizationId) async {
    final List<FolderEntity> response = await _repository.getFolders(organizationId);
    return response;
  }
}
