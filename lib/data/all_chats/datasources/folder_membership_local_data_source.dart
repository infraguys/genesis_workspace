import 'package:genesis_workspace/data/all_chats/dao/folder_item_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

@injectable
class FolderMembershipLocalDataSource {
  final FolderItemDao _dao;
  FolderMembershipLocalDataSource(this._dao);

  Future<void> setChatFolders({
    required int chatId,
    required List<String> folderUuids,
    required int organizationId,
  }) async {
    await _dao.setChatFolders(
      chatId: chatId,
      folderUuids: folderUuids,
      organizationId: organizationId,
    );
  }

  Future<List<String>> getFolderUuidsForChat({
    required int chatId,
    required int organizationId,
  }) =>
      _dao.getFolderUuidsForChat(
        chatId: chatId,
        organizationId: organizationId,
      );

  Future<void> deleteByFolderUuid(String folderUuid, int organizationId) =>
      _dao.deleteByFolderUuid(folderUuid, organizationId);

  Future<List<FolderItem>> getItemsForFolder(String folderUuid, int organizationId) =>
      _dao.getItemsForFolder(folderUuid, organizationId);
}
