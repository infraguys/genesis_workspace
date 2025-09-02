import 'package:drift/drift.dart';

class RecentDms extends Table {
  IntColumn get dmId => integer()();

  @override
  Set<Column> get primaryKey => {dmId};
}
