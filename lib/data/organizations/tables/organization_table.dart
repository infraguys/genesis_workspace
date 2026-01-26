import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/common/converters/unread_messages_converter.dart';

class Organizations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get baseUrl => text()();
  TextColumn get meetingUrl => text().nullable()();
  TextColumn get unreadMessages => text().map(const UnreadMessagesConverter()).withDefault(const Constant('[]'))();
  IntColumn get maxStreamNameLength => integer().nullable()();
  IntColumn get maxStreamDescriptionLength => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {baseUrl},
    {id},
  ];
}
