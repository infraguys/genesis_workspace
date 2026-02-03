import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';

class PinnedChats extends Table {
  TextColumn get uuid => text()();
  TextColumn get folderUuid => text().references(Folders, #uuid, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer().nullable()();
  IntColumn get chatId => integer()();
  DateTimeColumn get pinnedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get organizationId => integer().references(Organizations, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {uuid};

  @override
  List<Set<Column>> get uniqueKeys => [
    {folderUuid, chatId},
  ];
}
