import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  IntColumn get iconCodePoint => integer()();

  IntColumn get backgroundColorValue => integer().nullable()();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  TextColumn get systemType => text().nullable()();
  IntColumn get organizationId =>
      integer().references(Organizations, #id, onDelete: KeyAction.cascade)();
}
