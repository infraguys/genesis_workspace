import 'package:genesis_workspace/data/all_chats/dao/folder_item_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

@injectable
class FolderMembershipLocalDataSource {
  final FolderItemDao _dao;
  FolderMembershipLocalDataSource(this._dao);

  Future<void> setChatFolders({
    required int chatId,
    required List<int> folderIds,
    required int organizationId,
  }) async {
    await _dao.setChatFolders(
      chatId: chatId,
      folderIds: folderIds,
      organizationId: organizationId,
    );
  }

  Future<List<int>> getFolderIdsForChat({
    required int chatId,
    required int organizationId,
  }) =>
      _dao.getFolderIdsForChat(
        chatId: chatId,
        organizationId: organizationId,
      );

  Future<void> deleteByFolderId(int folderId, int organizationId) =>
      _dao.deleteByFolderId(folderId, organizationId);

  Future<List<FolderItem>> getItemsForFolder(int folderId, int organizationId) =>
      _dao.getItemsForFolder(folderId, organizationId);
}
