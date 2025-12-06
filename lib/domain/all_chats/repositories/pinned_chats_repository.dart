import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';

abstract class PinnedChatsRepository {
  Future<List<PinnedChatEntity>> getPinnedChats({required String folderUuid});

  Future<void> pinChat({
    required String folderUuid,
    required int chatId,
    int? orderIndex,
  });

  Future<void> unpinChat({
    required String folderUuid,
    required int chatId,
  });

  Future<void> updatePinnedChatOrder({
    required String folderUuid,
    required String folderItemUuid,
    int? orderIndex,
  });
}
