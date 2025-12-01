import 'package:genesis_workspace/data/all_chats/datasources/folder_membership_local_data_source.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FolderMembershipRepository)
class FolderMembershipRepositoryImpl implements FolderMembershipRepository {
  final FolderMembershipLocalDataSource _localDataSource;
  FolderMembershipRepositoryImpl(this._localDataSource);

  @override
  Future<void> setFoldersForChat(
    int chatId,
    List<int> folderIds, {
    required int organizationId,
  }) async {
    await _localDataSource.setChatFolders(
      chatId: chatId,
      folderIds: folderIds,
      organizationId: organizationId,
    );
  }

  @override
  Future<List<int>> getFolderIdsForChat(
    int chatId, {
    required int organizationId,
  }) async {
    return _localDataSource.getFolderIdsForChat(
      chatId: chatId,
      organizationId: organizationId,
    );
  }

  @override
  Future<void> removeAllForFolder(int folderId, {required int organizationId}) =>
      _localDataSource.deleteByFolderId(folderId, organizationId);

  @override
  Future<FolderMembers> getMembersForFolder(int folderId, {required int organizationId}) async {
    final rows = await _localDataSource.getItemsForFolder(folderId, organizationId);
    final chatIds = rows.map((r) => r.chatId).toList(growable: false);
    return FolderMembers(chatIds: chatIds);
  }
}
