import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/all_chats/datasources/folder_items_remote_data_source.dart';
import 'package:genesis_workspace/data/all_chats/datasources/pinned_chats_local_data_source.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_item.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PinnedChatsRepository)
class PinnedChatsRepositoryImpl implements PinnedChatsRepository {
  final FolderItemsRemoteDataSource _remoteDataSource;
  final PinnedChatsLocalDataSource _localDataSource;

  PinnedChatsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<PinnedChatEntity>> getPinnedChats({required String folderUuid}) async {
    final List<FolderItem> items = await _remoteDataSource.getFolderItems(folderUuid);
    final pins = items
        .where((item) => item.pinnedAt != null)
        .map(
          (item) => PinnedChatEntity(
            folderItemUuid: item.uuid,
            folderUuid: item.folderUuid,
            chatId: item.chatId,
            orderIndex: item.orderIndex,
            pinnedAt: item.pinnedAt,
            updatedAt: item.updatedAt,
          ),
        )
        .toList();
    final orgId = AppConstants.selectedOrganizationId ?? -1;
    await _localDataSource.syncFolderPins(folderUuid: folderUuid, organizationId: orgId, pins: pins);
    return pins;
  }

  @override
  Future<void> pinChat({
    required String folderUuid,
    required int chatId,
    int? orderIndex,
  }) async {
    final FolderItem item = await _remoteDataSource.ensureFolderItem(folderUuid, chatId);
    await _remoteDataSource.pinFolderItem(folderUuid: folderUuid, folderItemUuid: item.uuid);
    await getPinnedChats(folderUuid: folderUuid);
  }

  @override
  Future<void> unpinChat({
    required String folderUuid,
    required int chatId,
  }) async {
    final FolderItem? item = await _remoteDataSource.findFolderItem(folderUuid, chatId);
    if (item == null) return;
    await _remoteDataSource.unpinFolderItem(folderUuid: folderUuid, folderItemUuid: item.uuid);
    await getPinnedChats(folderUuid: folderUuid);
  }

  @override
  Future<void> updatePinnedChatOrder({
    required String folderUuid,
    required String folderItemUuid,
    int? orderIndex,
  }) async {
    if (orderIndex == null) return;
    await _remoteDataSource.updateFolderItem(
      folderUuid: folderUuid,
      folderItemUuid: folderItemUuid,
      orderIndex: orderIndex,
    );
    await getPinnedChats(folderUuid: folderUuid);
  }
}
