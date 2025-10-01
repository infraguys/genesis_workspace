import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';

part 'folder_dao.g.dart';

@injectable
@DriftAccessor(tables: [Folders])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(AppDatabase db) : super(db);

  Future<int> insertFolder({
    required String title,
    required int iconCodePoint,
    int? backgroundColorValue,
    int unreadCount = 0,
  }) {
    return into(folders).insert(
      FoldersCompanion.insert(
        title: title,
        iconCodePoint: iconCodePoint,
        backgroundColorValue: Value(backgroundColorValue),
        unreadCount: Value(unreadCount),
      ),
      mode: InsertMode.insert,
    );
  }

  Future<List<Folder>> getAll() {
    return (select(folders)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  Future<void> deleteById(int id) async {
    await (delete(folders)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> clear() => delete(folders).go();

  Future<int> updateFolder({
    required int id,
    String? title,
    int? iconCodePoint,
    int? backgroundColorValue,
    int? unreadCount,
  }) async {
    final companion = FoldersCompanion(
      title: title != null ? Value(title) : const Value.absent(),
      iconCodePoint:
          iconCodePoint != null ? Value(iconCodePoint) : const Value.absent(),
      backgroundColorValue: backgroundColorValue != null
          ? Value(backgroundColorValue)
          : const Value.absent(),
      unreadCount:
          unreadCount != null ? Value(unreadCount) : const Value.absent(),
    );
    return (update(folders)..where((tbl) => tbl.id.equals(id))).write(companion);
  }
}
