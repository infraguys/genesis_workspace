import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/common/converters/unread_messages_converter.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';

class Folders extends Table {
  TextColumn get uuid => text()();
  TextColumn get title => text()();
  IntColumn get backgroundColorValue => integer().nullable()();
  TextColumn get unreadMessages => text().map(const UnreadMessagesConverter()).withDefault(const Constant('[]'))();
  TextColumn get systemType => text()(); // not null
  IntColumn get organizationId => integer().references(Organizations, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {uuid};
}
