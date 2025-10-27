import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';

abstract class PinnedChatsRepository {
  Future<void> pinChat({
    required int folderId,
    required int chatId,
    required int orderIndex,
    required PinnedChatType type,
    required int organizationId,
  });
  Future<void> unpinChat(int id);
  Future<List<PinnedChatEntity>> getPinnedChats({
    required int folderId,
    required int organizationId,
  });
  Future<void> updatePinnedChatOrder({
    required int folderId,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
    required int organizationId,
  });
}
