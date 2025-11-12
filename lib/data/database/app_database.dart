import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart';
import 'package:genesis_workspace/data/all_chats/dao/folder_item_dao.dart';
import 'package:genesis_workspace/data/all_chats/dao/pinned_chats_dao.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_item_mapping_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
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
  int get schemaVersion => 14;

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
        await migrator.deleteTable('folders');
        await migrator.deleteTable('folder_items');
        await migrator.deleteTable('pinned_chats');
        await migrator.deleteTable('recent_dms');
        await migrator.create(folders);
        await migrator.create(folderItems);
        await migrator.create(pinnedChats);
        await migrator.create(recentDms);
      }
      if (from < 8) {
        await migrator.alterTable(
          TableMigration(
            pinnedChats,
            // newColumns: [pinnedChats.type],
            // columnTransformer: {pinnedChats.type: const Constant('dm')},
          ),
        );
      }
      if (from < 9) {
        await migrator.createTable(organizations);
      }
      if (from < 10) {
        await migrator.deleteTable('folder_items');
        await migrator.deleteTable('pinned_chats');
        await migrator.deleteTable('folders');
        await migrator.create(folders);
        await migrator.create(folderItems);
        await migrator.create(pinnedChats);
      }
      if (from < 11) {
        await migrator.alterTable(
          TableMigration(
            organizations,
            newColumns: [organizations.unreadCount],
            columnTransformer: {
              organizations.unreadCount: const Constant(0),
            },
          ),
        );
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

        await transaction(() async {
          await customStatement('ALTER TABLE folders RENAME TO folders_old;');
          await migrator.createTable(folders);
          if (defaultOrganizationId != null) {
            await customStatement(
              'INSERT INTO folders '
              '(id, title, icon_code_point, background_color_value, unread_count, system_type, organization_id) '
              'SELECT id, title, icon_code_point, background_color_value, unread_count, system_type, $defaultOrganizationId '
              'FROM folders_old;',
            );
          }
          await customStatement('DROP TABLE folders_old;');

          await customStatement('ALTER TABLE folder_items RENAME TO folder_items_old;');
          await migrator.createTable(folderItems);
          if (defaultOrganizationId != null) {
            final legacyChatIdColumn =
                await _resolveLegacyFolderItemsChatColumn('folder_items_old');
            await customStatement(
              'INSERT INTO folder_items '
              '(id, folder_id, organization_id, chat_id) '
              'SELECT id, folder_id, $defaultOrganizationId, $legacyChatIdColumn '
              'FROM folder_items_old;',
            );
          }
          await customStatement('DROP TABLE folder_items_old;');

          await customStatement('ALTER TABLE pinned_chats RENAME TO pinned_chats_old;');
          await migrator.createTable(pinnedChats);
          if (defaultOrganizationId != null) {
            await customStatement(
              'INSERT INTO pinned_chats '
              '(id, folder_id, order_index, chat_id, pinned_at, organization_id) '
              'SELECT id, folder_id, order_index, chat_id, pinned_at, $defaultOrganizationId '
              'FROM pinned_chats_old;',
            );
          }
          await customStatement('DROP TABLE pinned_chats_old;');
        });
      }
      if (from < 13) {
        await transaction(() async {
          await customStatement('ALTER TABLE pinned_chats RENAME TO pinned_chats_old;');
          await migrator.createTable(pinnedChats);
          await customStatement(
            'INSERT INTO pinned_chats '
            '(id, folder_id, order_index, chat_id, pinned_at, organization_id) '
            'SELECT id, folder_id, order_index, chat_id, pinned_at, organization_id '
            'FROM pinned_chats_old;',
          );
          await customStatement('DROP TABLE pinned_chats_old;');
        });
      }
      if (from < 14) {
        await transaction(() async {
          await customStatement('ALTER TABLE folder_items RENAME TO folder_items_old;');
          await migrator.createTable(folderItems);
          final legacyChatIdColumn =
              await _resolveLegacyFolderItemsChatColumn('folder_items_old');
          await customStatement(
            'INSERT INTO folder_items '
            '(id, folder_id, organization_id, chat_id) '
            'SELECT id, folder_id, organization_id, $legacyChatIdColumn '
            'FROM folder_items_old;',
          );
          await customStatement('DROP TABLE folder_items_old;');
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

  /// Determines which legacy column should be used when migrating folder items.
  Future<String> _resolveLegacyFolderItemsChatColumn(String tableName) async {
    final columnInfo = await customSelect('PRAGMA table_info($tableName);').get();
    final columnNames = columnInfo
        .map((row) => row.data['name'] as String?)
        .whereType<String>()
        .toSet();
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
