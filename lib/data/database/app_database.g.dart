// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecentDmsTable extends RecentDms
    with TableInfo<$RecentDmsTable, RecentDm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentDmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dmIdMeta = const VerificationMeta('dmId');
  @override
  late final GeneratedColumn<int> dmId = GeneratedColumn<int>(
    'dm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [dmId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_dms';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentDm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dm_id')) {
      context.handle(
        _dmIdMeta,
        dmId.isAcceptableOrUnknown(data['dm_id']!, _dmIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dmId};
  @override
  RecentDm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentDm(
      dmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dm_id'],
      )!,
    );
  }

  @override
  $RecentDmsTable createAlias(String alias) {
    return $RecentDmsTable(attachedDatabase, alias);
  }
}

class RecentDm extends DataClass implements Insertable<RecentDm> {
  final int dmId;
  const RecentDm({required this.dmId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dm_id'] = Variable<int>(dmId);
    return map;
  }

  RecentDmsCompanion toCompanion(bool nullToAbsent) {
    return RecentDmsCompanion(dmId: Value(dmId));
  }

  factory RecentDm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentDm(dmId: serializer.fromJson<int>(json['dmId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'dmId': serializer.toJson<int>(dmId)};
  }

  RecentDm copyWith({int? dmId}) => RecentDm(dmId: dmId ?? this.dmId);
  RecentDm copyWithCompanion(RecentDmsCompanion data) {
    return RecentDm(dmId: data.dmId.present ? data.dmId.value : this.dmId);
  }

  @override
  String toString() {
    return (StringBuffer('RecentDm(')
          ..write('dmId: $dmId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => dmId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RecentDm && other.dmId == this.dmId);
}

class RecentDmsCompanion extends UpdateCompanion<RecentDm> {
  final Value<int> dmId;
  const RecentDmsCompanion({this.dmId = const Value.absent()});
  RecentDmsCompanion.insert({this.dmId = const Value.absent()});
  static Insertable<RecentDm> custom({Expression<int>? dmId}) {
    return RawValuesInsertable({if (dmId != null) 'dm_id': dmId});
  }

  RecentDmsCompanion copyWith({Value<int>? dmId}) {
    return RecentDmsCompanion(dmId: dmId ?? this.dmId);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dmId.present) {
      map['dm_id'] = Variable<int>(dmId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentDmsCompanion(')
          ..write('dmId: $dmId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentDmsTable recentDms = $RecentDmsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recentDms];
}

typedef $$RecentDmsTableCreateCompanionBuilder =
    RecentDmsCompanion Function({Value<int> dmId});
typedef $$RecentDmsTableUpdateCompanionBuilder =
    RecentDmsCompanion Function({Value<int> dmId});

class $$RecentDmsTableFilterComposer
    extends Composer<_$AppDatabase, $RecentDmsTable> {
  $$RecentDmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dmId => $composableBuilder(
    column: $table.dmId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentDmsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentDmsTable> {
  $$RecentDmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dmId => $composableBuilder(
    column: $table.dmId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentDmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentDmsTable> {
  $$RecentDmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dmId =>
      $composableBuilder(column: $table.dmId, builder: (column) => column);
}

class $$RecentDmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentDmsTable,
          RecentDm,
          $$RecentDmsTableFilterComposer,
          $$RecentDmsTableOrderingComposer,
          $$RecentDmsTableAnnotationComposer,
          $$RecentDmsTableCreateCompanionBuilder,
          $$RecentDmsTableUpdateCompanionBuilder,
          (RecentDm, BaseReferences<_$AppDatabase, $RecentDmsTable, RecentDm>),
          RecentDm,
          PrefetchHooks Function()
        > {
  $$RecentDmsTableTableManager(_$AppDatabase db, $RecentDmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentDmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentDmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentDmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({Value<int> dmId = const Value.absent()}) =>
              RecentDmsCompanion(dmId: dmId),
          createCompanionCallback: ({Value<int> dmId = const Value.absent()}) =>
              RecentDmsCompanion.insert(dmId: dmId),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentDmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentDmsTable,
      RecentDm,
      $$RecentDmsTableFilterComposer,
      $$RecentDmsTableOrderingComposer,
      $$RecentDmsTableAnnotationComposer,
      $$RecentDmsTableCreateCompanionBuilder,
      $$RecentDmsTableUpdateCompanionBuilder,
      (RecentDm, BaseReferences<_$AppDatabase, $RecentDmsTable, RecentDm>),
      RecentDm,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentDmsTableTableManager get recentDms =>
      $$RecentDmsTableTableManager(_db, _db.recentDms);
}
