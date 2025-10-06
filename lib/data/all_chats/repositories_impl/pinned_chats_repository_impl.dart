import 'package:genesis_workspace/data/all_chats/datasources/pinned_chats_local_data_source.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PinnedChatsRepository)
class PinnedChatsRepositoryImpl implements PinnedChatsRepository {
  final PinnedChatsLocalDataSource _localDataSource;

  PinnedChatsRepositoryImpl(this._localDataSource);

  @override
  Future<List<PinnedChatEntity>> getPinnedChats(int folderId) async {
    final pinnedChats = await _localDataSource.getPinnedChats(folderId);
    final result = pinnedChats
        .map(
          (chat) => PinnedChatEntity(
            id: chat.id,
            folderId: chat.folderId,
            chatId: chat.chatId,
            pinnedAt: chat.pinnedAt,
            orderIndex: chat.orderIndex,
          ),
        )
        .toList();
    return result;
  }

  @override
  Future<void> pinChat({
    required int folderId,
    required int chatId,
    required int orderIndex,
  }) async {
    return await _localDataSource.pinChat(
      folderId: folderId,
      chatId: chatId,
      orderIndex: orderIndex,
    );
  }

  @override
  Future<void> unpinChat(int id) async {
    return await _localDataSource.unpinChat(id);
  }

  @override
  Future<void> updatePinnedChatOrder({
    required int folderId,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
  }) async {
    return await _localDataSource.updatePinnedChatOrder(
      folderId: folderId,
      movedChatId: movedChatId,
      previousChatId: previousChatId,
      nextChatId: nextChatId,
    );
  }
}
