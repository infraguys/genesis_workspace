import 'package:drift/drift.dart';

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  IntColumn get iconCodePoint => integer()();

  IntColumn get backgroundColorValue => integer().nullable()();

  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
}
