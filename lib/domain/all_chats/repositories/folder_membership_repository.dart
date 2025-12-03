import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';

abstract class FolderMembershipRepository {
  Future<void> setFoldersForChat(
    int chatId,
    List<String> folderUuids,
  );
  Future<List<String>> getFolderIdsForChat(int chatId);
  Future<void> removeAllForFolder(String folderUuid);
  Future<FolderMembers> getMembersForFolder(String folderUuid);
}
