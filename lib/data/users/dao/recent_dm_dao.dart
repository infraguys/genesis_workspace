// lib/data/users/dao/recent_dm_dao.dart
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/data/users/tables/recent_dm_table.dart';
import 'package:injectable/injectable.dart';

part 'recent_dm_dao.g.dart';

@injectable
@DriftAccessor(tables: [RecentDms])
class RecentDmDao extends DatabaseAccessor<AppDatabase> with _$RecentDmDaoMixin {
  RecentDmDao(AppDatabase database) : super(database);

  Future<int> insert(int directMessageId) async {
    try {
      return await into(recentDms).insert(
        RecentDmsCompanion.insert(dmId: Value(directMessageId)),
        mode: InsertMode.insertOrReplace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insertMany(Iterable<int> directMessageIds) async {
    await batch((Batch batch) {
      batch.insertAllOnConflictUpdate(
        recentDms,
        directMessageIds
            .map((int id) => RecentDmsCompanion.insert(dmId: Value(id)))
            .toList(growable: false),
      );
    });
  }

  Future<void> getAll() async {
    final recentDm = await select(recentDms).get();
    inspect(recentDm);
  }

  // Живой поток: обновится при любом изменении таблицы
  // Stream<List<RecentDmsData>> watchAll() {
  //   return (select(recentDms)..orderBy([(t) => OrderingTerm.asc(t.dmId)])).watch();
  // }

  Future<void> deleteById(int directMessageId) {
    return (delete(recentDms)..where((t) => t.dmId.equals(directMessageId))).go();
  }

  Future<void> clear() => delete(recentDms).go();

  // Пример транзакции
  Future<void> replaceAll(Iterable<int> newIds) async {
    await transaction(() async {
      await clear();
      await insertMany(newIds);
    });
  }
}
