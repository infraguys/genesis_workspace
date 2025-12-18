import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/all_chats/dao/folder_item_dao.dart';
import 'package:genesis_workspace/data/all_chats/dao/pinned_chats_dao.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_item_mapping_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/data/common/converters/unread_messages_converter.dart';
import 'package:genesis_workspace/data/organizations/dao/organizations_dao.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';
import 'package:genesis_workspace/data/users/dao/recent_dm_dao.dart';
import 'package:genesis_workspace/data/users/tables/recent_dm_table.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [RecentDms, Folders, FolderItems, PinnedChats, Organizations],
  daos: [RecentDmDao, FolderDao, FolderItemDao, PinnedChatsDao, OrganizationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 9) {
        await migrator.createTable(organizations);
      }
      if (from < 11) {
        final hasUnreadCountColumn = await _hasColumn('organizations', 'unread_count');
        if (!hasUnreadCountColumn) {
          await customStatement(
            'ALTER TABLE organizations ADD COLUMN unread_count INTEGER NOT NULL DEFAULT 0;',
          );
        }
      }
      if (from < 12) {
        int? defaultOrganizationId = AppConstants.selectedOrganizationId;
        if (defaultOrganizationId == null) {
          final existingOrganizations = await customSelect(
            'SELECT id FROM organizations ORDER BY id LIMIT 1',
            readsFrom: {organizations},
          ).get();
          if (existingOrganizations.isNotEmpty) {
            defaultOrganizationId = existingOrganizations.first.data['id'] as int;
          }
        }
      }
      if (from < 15) {
        await transaction(() async {
          await customStatement('ALTER TABLE organizations RENAME TO organizations_old;');
          await migrator.createTable(organizations);
          await customStatement(
            'INSERT INTO organizations '
            '(id, name, icon, base_url, unread_messages) '
            "SELECT id, name, icon, base_url, '[]' FROM organizations_old;",
          );
          await customStatement('DROP TABLE organizations_old;');
        });
      }
      if (from < 17) {
        await transaction(() async {
          await migrator.deleteTable('folder_items');
          await migrator.deleteTable('pinned_chats');
          await migrator.deleteTable('folders');
          await migrator.createTable(folders);
          await migrator.createTable(folderItems);
          await migrator.createTable(pinnedChats);
        });
      }
      if (from < 18) {
        await migrator.alterTable(
          TableMigration(
            organizations,
            newColumns: [organizations.meetingUrl],
          ),
        );
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

  Future<void> clearAllData() async {
    await transaction(() async {
      await batch((batch) {
        batch.deleteAll(folderItems);
        batch.deleteAll(pinnedChats);
        batch.deleteAll(folders);
        batch.deleteAll(recentDms);
        batch.deleteAll(organizations);
      });
    });
  }

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final columnInfo = await customSelect('PRAGMA table_info($tableName);').get();
    return columnInfo.map((row) => row.data['name'] as String?).whereType<String>().contains(columnName);
  }

  /// Determines which legacy column should be used when migrating folder items.
  Future<String> _resolveLegacyFolderItemsChatColumn(String tableName) async {
    final columnInfo = await customSelect('PRAGMA table_info($tableName);').get();
    final columnNames = columnInfo.map((row) => row.data['name'] as String?).whereType<String>().toSet();
    if (columnNames.contains('target_id')) {
      return 'target_id';
    }
    if (columnNames.contains('chat_id')) {
      return 'chat_id';
    }
    throw StateError(
      'Unable to migrate $tableName because chat identifier column is missing.',
    );
  }
}
