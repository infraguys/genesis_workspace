import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:genesis_workspace/data/users/tables/recent_dm_table.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [RecentDms])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertRecentDm(int dmId) {
    return into(
      recentDms,
    ).insert(RecentDmsCompanion.insert(dmId: Value<int>(dmId)), mode: InsertMode.insertOrReplace);
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
