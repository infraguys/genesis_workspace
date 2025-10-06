import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';

abstract class PinnedChatsRepository {
  Future<void> pinChat({required int folderId, required int chatId});
  Future<void> unpinChat(int id);
  Future<List<PinnedChatEntity>> getPinnedChats(int folderId);
}
