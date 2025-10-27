import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';

import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';

abstract class FolderMembershipRepository {
  Future<void> setFoldersForTarget(
    FolderTarget target,
    List<int> folderIds, {
    required int organizationId,
  });
  Future<List<int>> getFolderIdsForTarget(
    FolderTarget target, {
    required int organizationId,
  });
  Future<void> removeAllForFolder(int folderId, {required int organizationId});
  Future<FolderMembers> getMembersForFolder(int folderId, {required int organizationId});
}
