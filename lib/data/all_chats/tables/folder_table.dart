import 'package:drift/drift.dart';

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  // Store IconData.codePoint. We use Material Icons by default.
  IntColumn get iconCodePoint => integer()();

  // ARGB int value for color. Nullable.
  IntColumn get backgroundColorValue => integer().nullable()();

  // Optional unread counter (can be computed elsewhere). Defaults to 0.
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
}

