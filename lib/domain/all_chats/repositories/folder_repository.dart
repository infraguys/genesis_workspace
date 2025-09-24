import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';

abstract class FolderRepository {
  Future<void> addFolder(FolderItemEntity folder);
  Future<List<FolderItemEntity>> getFolders();
}

