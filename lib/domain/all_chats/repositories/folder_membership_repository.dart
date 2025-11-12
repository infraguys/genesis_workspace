import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';

abstract class FolderMembershipRepository {
  Future<void> setFoldersForChat(
    int chatId,
    List<int> folderIds, {
    required int organizationId,
  });
  Future<List<int>> getFolderIdsForChat(int chatId, {required int organizationId});
  Future<void> removeAllForFolder(int folderId, {required int organizationId});
  Future<FolderMembers> getMembersForFolder(int folderId, {required int organizationId});
}
