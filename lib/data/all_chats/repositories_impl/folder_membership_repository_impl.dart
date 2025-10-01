import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/data/all_chats/datasources/folder_membership_local_data_source.dart';

@Injectable(as: FolderMembershipRepository)
class FolderMembershipRepositoryImpl implements FolderMembershipRepository {
  final FolderMembershipLocalDataSource _local;
  FolderMembershipRepositoryImpl(this._local);

  String _typeToString(FolderTargetType type) {
    switch (type) {
      case FolderTargetType.dm:
        return 'dm';
      case FolderTargetType.channel:
        return 'channel';
    }
  }

  @override
  Future<void> setFoldersForTarget(FolderTarget target, List<int> folderIds) async {
    await _local.setItemFolders(
      itemType: _typeToString(target.type),
      targetId: target.targetId,
      folderIds: folderIds,
      topicName: target.topicName,
    );
  }

  @override
  Future<List<int>> getFolderIdsForTarget(FolderTarget target) async {
    return _local.getFolderIdsForItem(
      itemType: _typeToString(target.type),
      targetId: target.targetId,
      topicName: target.topicName,
    );
  }

  @override
  Future<void> removeAllForFolder(int folderId) => _local.deleteByFolderId(folderId);

  @override
  Future<FolderMembers> getMembersForFolder(int folderId) async {
    final rows = await _local.getItemsForFolder(folderId);
    final dm = <int>[];
    final channels = <int>[];
    for (final r in rows) {
      if (r.itemType == 'dm') dm.add(r.targetId);
      if (r.itemType == 'channel') channels.add(r.targetId);
    }
    return FolderMembers(dmUserIds: dm, channelIds: channels);
  }
}
