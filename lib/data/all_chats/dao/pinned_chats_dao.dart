// lib/data/all_chats/dao/pinned_folder_item_dao.dart
import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_item_mapping_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

part 'pinned_chats_dao.g.dart';

@injectable
@DriftAccessor(tables: [PinnedChats, FolderItems, Folders])
class PinnedChatsDao extends DatabaseAccessor<AppDatabase> with _$PinnedChatsDaoMixin {
  PinnedChatsDao(super.db);

  Future<void> pinChat({required int folderId, required int chatId, int? orderIndex}) async {
    await into(pinnedChats).insert(
      PinnedChatsCompanion(
        folderId: Value(folderId),
        chatId: Value(chatId),
        orderIndex: orderIndex != null ? Value(orderIndex) : const Value.absent(),
        pinnedAt: const Value.absent(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> unpinChat(int id) async {
    await delete(pinnedChats).delete(PinnedChatsCompanion(id: Value(id)));
  }

  Future<List<PinnedChat>> getPinnedChats(int folderId) async {
    final allFolders = await select(folders).get();
    final folder = allFolders.firstWhere((folder) => folder.id == folderId);
    final pinnedChatsList = await select(pinnedChats).get();
    final result = pinnedChatsList.where((pinnedChat) => pinnedChat.folderId == folder.id).toList();
    return result;
  }
}
