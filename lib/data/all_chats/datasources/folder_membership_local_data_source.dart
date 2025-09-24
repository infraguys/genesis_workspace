import 'package:genesis_workspace/data/all_chats/dao/folder_item_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

@injectable
class FolderMembershipLocalDataSource {
  final FolderItemDao _dao;
  FolderMembershipLocalDataSource(this._dao);

  Future<void> setItemFolders({
    required String itemType,
    required int targetId,
    required List<int> folderIds,
    String? topicName,
  }) async {
    await _dao.setItemFolders(
      itemType: itemType,
      targetId: targetId,
      folderIds: folderIds,
      topicName: topicName,
    );
  }

  Future<List<int>> getFolderIdsForItem({
    required String itemType,
    required int targetId,
    String? topicName,
  }) => _dao.getFolderIdsForItem(itemType: itemType, targetId: targetId, topicName: topicName);

  Future<void> deleteByFolderId(int folderId) => _dao.deleteByFolderId(folderId);

  Future<List<FolderItem>> getItemsForFolder(int folderId) => _dao.getItemsForFolder(folderId);
}
