import 'package:genesis_workspace/data/all_chats/datasources/folder_items_remote_data_source.dart';
import 'package:genesis_workspace/data/all_chats/datasources/folders_remote_data_source.dart';
import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FolderMembershipRepository)
class FolderMembershipRepositoryImpl implements FolderMembershipRepository {
  final FolderItemsRemoteDataSource _remoteDataSource;
  final FoldersRemoteDataSource _foldersRemoteDataSource;
  FolderMembershipRepositoryImpl(this._remoteDataSource, this._foldersRemoteDataSource);

  @override
  Future<void> setFoldersForChat(
    int chatId,
    List<String> folderUuids,
  ) async {
    final folders = await _foldersRemoteDataSource.getAll();
    final allFolderUuids = folders.where((f) => f.systemType != FolderSystemType.all).map((f) => f.uuid).toList();

    for (final folderUuid in allFolderUuids) {
      final items = await _remoteDataSource.getFolderItems(folderUuid);
      final hasChat = items.any((item) => item.chatId == chatId);
      final shouldHave = folderUuids.contains(folderUuid);

      if (shouldHave && !hasChat) {
        await _remoteDataSource.createFolderItem(folderUuid: folderUuid, chatId: chatId);
      } else if (!shouldHave && hasChat) {
        final item = items.firstWhere((e) => e.chatId == chatId);
        await _remoteDataSource.deleteFolderItem(
          folderUuid: folderUuid,
          folderItemUuid: item.uuid,
        );
      }
    }
  }

  @override
  Future<List<String>> getFolderIdsForChat(
    int chatId,
  ) async {
    final folders = await _foldersRemoteDataSource.getAll();
    final result = <String>[];
    for (final folder in folders.where((f) => f.systemType != FolderSystemType.all)) {
      final items = await _remoteDataSource.getFolderItems(folder.uuid);
      if (items.any((item) => item.chatId == chatId)) {
        result.add(folder.uuid);
      }
    }
    return result;
  }

  @override
  Future<void> removeAllForFolder(String folderUuid) async {
    final items = await _remoteDataSource.getFolderItems(folderUuid);
    for (final item in items) {
      await _remoteDataSource.deleteFolderItem(folderUuid: folderUuid, folderItemUuid: item.uuid);
    }
  }

  @override
  Future<FolderMembers> getMembersForFolder(String folderUuid) async {
    final items = await _remoteDataSource.getFolderItems(folderUuid);
    final chatIds = items.map((r) => r.chatId).toList(growable: false);
    return FolderMembers(chatIds: chatIds);
  }
}
