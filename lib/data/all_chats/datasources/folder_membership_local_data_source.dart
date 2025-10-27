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
    required int organizationId,
  }) async {
    await _dao.setItemFolders(
      itemType: itemType,
      targetId: targetId,
      folderIds: folderIds,
      topicName: topicName,
      organizationId: organizationId,
    );
  }

  Future<List<int>> getFolderIdsForItem({
    required String itemType,
    required int targetId,
    String? topicName,
    required int organizationId,
  }) =>
      _dao.getFolderIdsForItem(
        itemType: itemType,
        targetId: targetId,
        topicName: topicName,
        organizationId: organizationId,
      );

  Future<void> deleteByFolderId(int folderId, int organizationId) =>
      _dao.deleteByFolderId(folderId, organizationId);

  Future<List<FolderItem>> getItemsForFolder(int folderId, int organizationId) =>
      _dao.getItemsForFolder(folderId, organizationId);
}
