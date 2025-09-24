import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';

import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';

abstract class FolderMembershipRepository {
  Future<void> setFoldersForTarget(FolderTarget target, List<int> folderIds);
  Future<List<int>> getFolderIdsForTarget(FolderTarget target);
  Future<void> removeAllForFolder(int folderId);
  Future<FolderMembers> getMembersForFolder(int folderId);
}
