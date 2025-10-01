import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_item_mapping_table.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

part 'folder_item_dao.g.dart';

@injectable
@DriftAccessor(tables: [FolderItems])
class FolderItemDao extends DatabaseAccessor<AppDatabase> with _$FolderItemDaoMixin {
  FolderItemDao(AppDatabase db) : super(db);

  Future<void> setItemFolders({
    required String itemType,
    required int targetId,
    required List<int> folderIds,
    String? topicName,
  }) async {
    await transaction(() async {
      await (delete(folderItems)..where(
            (t) =>
                t.itemType.equals(itemType) &
                t.targetId.equals(targetId) &
                (topicName == null ? t.topicName.isNull() : t.topicName.equals(topicName)),
          ))
          .go();

      if (folderIds.isEmpty) return;
      final rows = folderIds
          .map(
            (fid) => FolderItemsCompanion.insert(
              folderId: Value(fid).value,
              itemType: itemType,
              targetId: targetId,
              topicName: Value(topicName),
            ),
          )
          .toList(growable: false);
      await batch((b) => b.insertAllOnConflictUpdate(folderItems, rows));
    });
  }

  Future<List<int>> getFolderIdsForItem({
    required String itemType,
    required int targetId,
    String? topicName,
  }) async {
    final query = select(folderItems)
      ..where((t) => t.itemType.equals(itemType) & t.targetId.equals(targetId));
    if (topicName == null) {
      query.where((t) => t.topicName.isNull());
    } else {
      query.where((t) => t.topicName.equals(topicName));
    }
    final rows = await query.get();
    return rows.map((r) => r.folderId).toList(growable: false);
  }

  Future<void> deleteByFolderId(int folderId) async {
    await (delete(folderItems)..where((t) => t.folderId.equals(folderId))).go();
  }

  Future<List<FolderItem>> getItemsForFolder(int folderId) async {
    final query = select(folderItems)..where((t) => t.folderId.equals(folderId));
    return query.get();
  }
}
