import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';

abstract class FolderRepository {
  Future<FolderEntity> addFolder(CreateFolderEntity folder);
  Future<List<FolderEntity>> getFolders(int organizationId);
  Future<void> updateFolder(FolderItemEntity folder);
  Future<void> deleteFolder(int id);
}
