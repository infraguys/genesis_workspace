import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';

abstract class FolderRepository {
  Future<void> addFolder(CreateFolderEntity folder);
  Future<List<Folder>> getFolders(int organizationId);
  Future<void> updateFolder(FolderItemEntity folder);
  Future<void> deleteFolder(int id);
}
