// lib/data/all_chats/tables/pinned_folder_item_table.dart
import 'package:drift/drift.dart';

class PinnedChats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId =>
      integer().customConstraint('REFERENCES folder_items(id) ON DELETE CASCADE')();
  IntColumn get orderIndex => integer().nullable()();
  IntColumn get chatId => integer()();
  DateTimeColumn get pinnedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {folderId, chatId},
  ];
}
