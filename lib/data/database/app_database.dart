import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/all_chats/dao/folder_item_dao.dart';
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
  daos: [RecentDmDao, FolderDao, FolderItemDao, PinnedChatsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  Future<bool> _tableExists(String tableName) async {
    final rows = await customSelect(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?;',
      variables: [Variable.withString('table'), Variable.withString(tableName)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName);').get();
    return rows.any((row) => row.data['name'] == columnName);
  }

  Future<void> _addColumnIfMissing({
    required String tableName,
    required String columnName,
    required String columnSql,
  }) async {
    final exists = await _columnExists(tableName, columnName);
    if (!exists) {
      await customStatement('ALTER TABLE $tableName ADD COLUMN $columnSql;');
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(folders);
      }
      if (from < 4) {
        await migrator.createTable(pinnedChats);
      }
      if (from < 5) {
        await migrator.deleteTable('folders');
        await migrator.createTable(folders);
      }
      if (from < 6) {
        await transaction(() async {
          // 1) Убедиться, что таблицы существуют
          if (!await _tableExists('folders')) {
            await migrator.createTable(folders);
          }
          if (!await _tableExists('pinned_chats')) {
            await migrator.createTable(pinnedChats);
          }

          // 2) Добавить недостающие колонки
          // system_type TEXT
          await _addColumnIfMissing(
            tableName: 'folders',
            columnName: 'system_type',
            columnSql: 'system_type TEXT',
          );

          // icon_index INTEGER
          await _addColumnIfMissing(
            tableName: 'folders',
            columnName: 'icon_index',
            columnSql: 'icon_index INTEGER',
          );

          // 3) Бэкфилл icon_index из icon_code_point (если пусто)
          await customStatement('''
        UPDATE folders
        SET icon_index = CASE icon_code_point
          WHEN ${Icons.folder.codePoint} THEN 0
          WHEN ${Icons.star.codePoint} THEN 1
          WHEN ${Icons.work.codePoint} THEN 2
          WHEN ${Icons.chat_bubble.codePoint} THEN 3
          WHEN ${Icons.mail.codePoint} THEN 4
          WHEN ${Icons.groups.codePoint} THEN 5
          WHEN ${Icons.code.codePoint} THEN 6
          WHEN ${Icons.task_alt.codePoint} THEN 7
          WHEN ${Icons.push_pin.codePoint} THEN 8
          WHEN ${Icons.bookmark.codePoint} THEN 9
          WHEN ${Icons.bolt.codePoint} THEN 10
          WHEN ${Icons.calendar_today.codePoint} THEN 11
          WHEN ${Icons.description.codePoint} THEN 12
          WHEN ${Icons.campaign.codePoint} THEN 13
          WHEN ${Icons.bug_report.codePoint} THEN 14
          WHEN ${Icons.security.codePoint} THEN 15
          ELSE 0
        END
        WHERE icon_index IS NULL;
      ''');

          // 4) Создать системную папку "All" (system_type='all'), если её нет
          await customStatement(
            '''
        INSERT INTO folders (title, icon_code_point, background_color_value, unread_count, system_type, icon_index)
        SELECT ?, ?, NULL, 0, 'all', 0
        WHERE NOT EXISTS (SELECT 1 FROM folders WHERE system_type = 'all');
      ''',
            ['All', Icons.folder.codePoint],
          );

          // 5) Уникальный индекс на system_type
          await customStatement('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_folders_system_type
        ON folders(system_type);
      ''');

          // (опционально) любые другие фиксы
        });
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
