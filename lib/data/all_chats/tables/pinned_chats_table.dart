import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';

enum PinnedChatType { dm, channel, group }

class PinnedChats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer().references(Folders, #id, onDelete: KeyAction.cascade)();
  IntColumn get orderIndex => integer().nullable()();
  IntColumn get chatId => integer()();
  DateTimeColumn get pinnedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get organizationId => integer().references(Organizations, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {folderId, chatId},
  ];
}
