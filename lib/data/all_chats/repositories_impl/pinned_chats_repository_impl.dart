import 'package:genesis_workspace/data/all_chats/datasources/folder_items_remote_data_source.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_item.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PinnedChatsRepository)
class PinnedChatsRepositoryImpl implements PinnedChatsRepository {
  final FolderItemsRemoteDataSource _remoteDataSource;

  PinnedChatsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PinnedChatEntity>> getPinnedChats({required String folderUuid}) async {
    final List<FolderItem> items = await _remoteDataSource.getFolderItems(folderUuid);
    return items
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
  }

  @override
  Future<void> pinChat({
    required String folderUuid,
    required int chatId,
    int? orderIndex,
  }) async {
    final FolderItem item = await _remoteDataSource.ensureFolderItem(folderUuid, chatId);
    await _remoteDataSource.pinFolderItem(folderUuid: folderUuid, folderItemUuid: item.uuid);
  }

  @override
  Future<void> unpinChat({
    required String folderUuid,
    required int chatId,
  }) async {
    final FolderItem? item = await _remoteDataSource.findFolderItem(folderUuid, chatId);
    if (item == null) return;
    await _remoteDataSource.unpinFolderItem(folderUuid: folderUuid, folderItemUuid: item.uuid);
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
  }
}
