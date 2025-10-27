import 'package:genesis_workspace/data/all_chats/dao/pinned_chats_dao.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

@injectable
class PinnedChatsLocalDataSource {
  final PinnedChatsDao _dao;
  PinnedChatsLocalDataSource(this._dao);

  Future<void> pinChat({
    required int folderId,
    required int chatId,
    required int orderIndex,
    required PinnedChatType type,
    required int organizationId,
  }) async {
    return await _dao.pinChat(
      folderId: folderId,
      chatId: chatId,
      type: type,
      organizationId: organizationId,
    );
  }

  Future<void> unpinChat(int id) async {
    return await _dao.unpinById(id);
  }

  Future<List<PinnedChat>> getPinnedChats({
    required int folderId,
    required int organizationId,
  }) async {
    return await _dao.getPinnedChats(folderId, organizationId);
  }

  Future<void> updatePinnedChatOrder({
    required int folderId,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
    required int organizationId,
  }) async {
    return await _dao.moveBetween(
      folderId: folderId,
      movedChatId: movedChatId,
      previousChatId: previousChatId,
      nextChatId: nextChatId,
      organizationId: organizationId,
    );
  }
}
