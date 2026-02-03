import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/dao/pinned_chats_dao.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class PinnedChatsLocalDataSource {
  final PinnedChatsDao _dao;
  PinnedChatsLocalDataSource(this._dao);

  Future<void> pinChat({
    required String folderUuid,
    required int chatId,
    required int organizationId,
  }) async {
    return await _dao.pinChat(
      folderUuid: folderUuid,
      chatId: chatId,
      organizationId: organizationId,
    );
  }

  Future<void> unpinChat({
    required String folderUuid,
    required int chatId,
    required int organizationId,
  }) async {
    return await _dao.unpinByIds(
      folderUuid: folderUuid,
      chatId: chatId,
      organizationId: organizationId,
    );
  }

  Future<List<PinnedChat>> getPinnedChats({
    required String folderUuid,
    required int organizationId,
  }) async {
    return await _dao.getPinnedChats(folderUuid, organizationId);
  }

  Future<void> updatePinnedChatOrder({
    required String folderUuid,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
    required int organizationId,
  }) async {
    return await _dao.moveBetween(
      folderUuid: folderUuid,
      movedChatId: movedChatId,
      previousChatId: previousChatId,
      nextChatId: nextChatId,
      organizationId: organizationId,
    );
  }

  Future<void> syncFolderPins({
    required String folderUuid,
    required int organizationId,
    required List<PinnedChatEntity> pins,
  }) async {
    await (_dao.delete(_dao.pinnedChats)..where(
          (t) => t.folderUuid.equals(folderUuid) & t.organizationId.equals(organizationId),
        ))
        .go();

    final rows = pins.map(
      (p) => PinnedChatsCompanion.insert(
        uuid: p.folderItemUuid,
        folderUuid: folderUuid,
        chatId: p.chatId,
        orderIndex: Value(p.orderIndex),
        pinnedAt: Value(p.pinnedAt),
        updatedAt: Value(p.updatedAt),
        organizationId: organizationId,
      ),
    );
    await _dao.batch((b) => b.insertAllOnConflictUpdate(_dao.pinnedChats, rows));
  }
}
