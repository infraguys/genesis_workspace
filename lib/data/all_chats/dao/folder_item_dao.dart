import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_item_mapping_table.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

part 'folder_item_dao.g.dart';

@injectable
@DriftAccessor(tables: [FolderItems])
class FolderItemDao extends DatabaseAccessor<AppDatabase> with _$FolderItemDaoMixin {
  FolderItemDao(AppDatabase db) : super(db);

  Future<void> setChatFolders({
    required int chatId,
    required List<String> folderUuids,
    required int organizationId,
  }) async {
    await transaction(() async {
      await (delete(folderItems)..where(
            (t) => t.chatId.equals(chatId) & t.organizationId.equals(organizationId),
          ))
          .go();

      if (folderUuids.isEmpty) return;
      final rows = folderUuids
          .map(
            (fid) => FolderItemsCompanion.insert(
              uuid: '${fid}_$chatId',
              folderUuid: fid,
              chatId: chatId,
              organizationId: organizationId,
            ),
          )
          .toList(growable: false);
      await batch((b) => b.insertAllOnConflictUpdate(folderItems, rows));
    });
  }

  Future<List<String>> getFolderUuidsForChat({
    required int chatId,
    required int organizationId,
  }) async {
    final query = select(folderItems)
      ..where(
        (t) => t.chatId.equals(chatId) & t.organizationId.equals(organizationId),
      );
    final rows = await query.get();
    return rows.map((r) => r.folderUuid).toList(growable: false);
  }

  Future<void> deleteByFolderUuid(String folderUuid, int organizationId) async {
    await (delete(folderItems)..where(
          (t) => t.folderUuid.equals(folderUuid) & t.organizationId.equals(organizationId),
        ))
        .go();
  }

  Future<List<FolderItem>> getItemsForFolder(String folderUuid, int organizationId) async {
    final query = select(folderItems)
      ..where(
        (t) => t.folderUuid.equals(folderUuid) & t.organizationId.equals(organizationId),
      );
    return query.get();
  }
}
