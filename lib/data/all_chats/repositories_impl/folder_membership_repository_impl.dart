import 'package:genesis_workspace/data/all_chats/datasources/folder_membership_local_data_source.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FolderMembershipRepository)
class FolderMembershipRepositoryImpl implements FolderMembershipRepository {
  final FolderMembershipLocalDataSource _localDataSource;
  FolderMembershipRepositoryImpl(this._localDataSource);

  String _typeToString(FolderTargetType type) {
    switch (type) {
      case FolderTargetType.dm:
        return 'dm';
      case FolderTargetType.channel:
        return 'channel';
      case FolderTargetType.group:
        return 'group';
    }
  }

  @override
  Future<void> setFoldersForTarget(FolderTarget target, List<int> folderIds) async {
    await _localDataSource.setItemFolders(
      itemType: _typeToString(target.type),
      targetId: target.targetId,
      folderIds: folderIds,
      topicName: target.topicName,
    );
  }

  @override
  Future<List<int>> getFolderIdsForTarget(FolderTarget target) async {
    return _localDataSource.getFolderIdsForItem(
      itemType: _typeToString(target.type),
      targetId: target.targetId,
      topicName: target.topicName,
    );
  }

  @override
  Future<void> removeAllForFolder(int folderId) => _localDataSource.deleteByFolderId(folderId);

  @override
  Future<FolderMembers> getMembersForFolder(int folderId) async {
    final rows = await _localDataSource.getItemsForFolder(folderId);
    final dm = <int>[];
    final channels = <int>[];
    final groups = <int>[];
    for (final r in rows) {
      if (r.itemType == 'dm') dm.add(r.targetId);
      if (r.itemType == 'channel') channels.add(r.targetId);
      if (r.itemType == 'group') groups.add(r.targetId);
    }
    return FolderMembers(dmUserIds: dm, channelIds: channels, groupChatIds: groups);
  }
}
