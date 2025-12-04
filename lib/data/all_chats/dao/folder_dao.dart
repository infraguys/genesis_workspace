import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

part 'folder_dao.g.dart';

@injectable
@DriftAccessor(tables: [Folders])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(AppDatabase db) : super(db);

  Future<int> insertFolder({
    required String uuid,
    required String title,
    int? backgroundColorValue,
    Set<int> unreadMessages = const <int>{},
    required int organizationId,
    required String systemType,
  }) {
    return into(folders).insert(
      FoldersCompanion.insert(
        uuid: uuid,
        title: title,
        backgroundColorValue: Value(backgroundColorValue),
        unreadMessages: Value(unreadMessages),
        organizationId: organizationId,
        systemType: systemType,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<Folder>> getAll(int organizationId) {
    return (select(folders)
          ..where((tbl) => tbl.organizationId.equals(organizationId))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  Future<void> deleteByUuid(String uuid) async {
    await (delete(folders)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<void> clear() => delete(folders).go();

  Future<void> deleteByOrganization(int organizationId) async {
    await (delete(folders)..where((tbl) => tbl.organizationId.equals(organizationId))).go();
  }

  Future<int> updateFolder({
    required String uuid,
    String? title,
    int? backgroundColorValue,
    Set<int>? unreadMessages,
    String? systemType,
  }) async {
    final companion = FoldersCompanion(
      title: title != null ? Value(title) : const Value.absent(),
      backgroundColorValue: backgroundColorValue != null ? Value(backgroundColorValue) : const Value.absent(),
      unreadMessages: unreadMessages != null ? Value(unreadMessages) : const Value.absent(),
      systemType: systemType != null ? Value(systemType) : const Value.absent(),
    );
    return (update(folders)..where((tbl) => tbl.uuid.equals(uuid))).write(companion);
  }
}
