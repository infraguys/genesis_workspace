import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/all_chats/dao/pinned_chats_dao.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_item_mapping_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/data/users/dao/recent_dm_dao.dart';
import 'package:genesis_workspace/data/users/tables/recent_dm_table.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [RecentDms, Folders, FolderItems, PinnedChats],
  daos: [RecentDmDao, FolderDao, PinnedChatsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(folders);
      }
      if (from < 3) {
        await migrator.createTable(folderItems);
      }
      if (from < 4) {
        await migrator.createTable(pinnedChats);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @disposeMethod
  Future<void> dispose() => close();
}
