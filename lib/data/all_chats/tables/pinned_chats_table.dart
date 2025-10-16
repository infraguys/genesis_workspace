import 'package:drift/drift.dart';

enum PinnedChatType { dm, channel, group }

class PinnedChats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId =>
      integer().customConstraint('REFERENCES folders(id) ON DELETE CASCADE')();
  IntColumn get orderIndex => integer().nullable()();
  IntColumn get chatId => integer()();
  DateTimeColumn get pinnedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get type => textEnum<PinnedChatType>()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {folderId, chatId},
  ];
}
