import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';

abstract class FolderRepository {
  Future<FolderEntity> addFolder(CreateFolderEntity folder);
  Future<List<FolderEntity>> getFolders(int organizationId);
  Future<FolderEntity> updateFolder(UpdateFolderEntity folder);
  Future<void> deleteFolder(DeleteFolderEntity folder);
}
