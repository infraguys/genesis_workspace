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

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backgroundColorValueMeta =
      const VerificationMeta('backgroundColorValue');
  @override
  late final GeneratedColumn<int> backgroundColorValue = GeneratedColumn<int>(
    'background_color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    iconCodePoint,
    backgroundColorValue,
    unreadCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('background_color_value')) {
      context.handle(
        _backgroundColorValueMeta,
        backgroundColorValue.isAcceptableOrUnknown(
          data['background_color_value']!,
          _backgroundColorValueMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      backgroundColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}background_color_value'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String title;
  final int iconCodePoint;
  final int? backgroundColorValue;
  final int unreadCount;
  const Folder({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.backgroundColorValue,
    required this.unreadCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    if (!nullToAbsent || backgroundColorValue != null) {
      map['background_color_value'] = Variable<int>(backgroundColorValue);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      title: Value(title),
      iconCodePoint: Value(iconCodePoint),
      backgroundColorValue: backgroundColorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(backgroundColorValue),
      unreadCount: Value(unreadCount),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      backgroundColorValue: serializer.fromJson<int?>(
        json['backgroundColorValue'],
      ),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'backgroundColorValue': serializer.toJson<int?>(backgroundColorValue),
      'unreadCount': serializer.toJson<int>(unreadCount),
    };
  }

  Folder copyWith({
    int? id,
    String? title,
    int? iconCodePoint,
    Value<int?> backgroundColorValue = const Value.absent(),
    int? unreadCount,
  }) => Folder(
    id: id ?? this.id,
    title: title ?? this.title,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    backgroundColorValue: backgroundColorValue.present
        ? backgroundColorValue.value
        : this.backgroundColorValue,
    unreadCount: unreadCount ?? this.unreadCount,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      backgroundColorValue: data.backgroundColorValue.present
          ? data.backgroundColorValue.value
          : this.backgroundColorValue,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('backgroundColorValue: $backgroundColorValue, ')
          ..write('unreadCount: $unreadCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, iconCodePoint, backgroundColorValue, unreadCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.title == this.title &&
          other.iconCodePoint == this.iconCodePoint &&
          other.backgroundColorValue == this.backgroundColorValue &&
          other.unreadCount == this.unreadCount);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> iconCodePoint;
  final Value<int?> backgroundColorValue;
  final Value<int> unreadCount;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.backgroundColorValue = const Value.absent(),
    this.unreadCount = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int iconCodePoint,
    this.backgroundColorValue = const Value.absent(),
    this.unreadCount = const Value.absent(),
  }) : title = Value(title),
       iconCodePoint = Value(iconCodePoint);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? iconCodePoint,
    Expression<int>? backgroundColorValue,
    Expression<int>? unreadCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (backgroundColorValue != null)
        'background_color_value': backgroundColorValue,
      if (unreadCount != null) 'unread_count': unreadCount,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? iconCodePoint,
    Value<int?>? backgroundColorValue,
    Value<int>? unreadCount,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (backgroundColorValue.present) {
      map['background_color_value'] = Variable<int>(backgroundColorValue.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('backgroundColorValue: $backgroundColorValue, ')
          ..write('unreadCount: $unreadCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentDmsTable recentDms = $RecentDmsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final RecentDmDao recentDmDao = RecentDmDao(this as AppDatabase);
  late final FolderDao folderDao = FolderDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recentDms, folders];
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
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      required String title,
      required int iconCodePoint,
      Value<int?> backgroundColorValue,
      Value<int> unreadCount,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> iconCodePoint,
      Value<int?> backgroundColorValue,
      Value<int> unreadCount,
    });

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backgroundColorValue => $composableBuilder(
    column: $table.backgroundColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backgroundColorValue => $composableBuilder(
    column: $table.backgroundColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get backgroundColorValue => $composableBuilder(
    column: $table.backgroundColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
          Folder,
          PrefetchHooks Function()
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<int?> backgroundColorValue = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                title: title,
                iconCodePoint: iconCodePoint,
                backgroundColorValue: backgroundColorValue,
                unreadCount: unreadCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int iconCodePoint,
                Value<int?> backgroundColorValue = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                title: title,
                iconCodePoint: iconCodePoint,
                backgroundColorValue: backgroundColorValue,
                unreadCount: unreadCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
      Folder,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentDmsTableTableManager get recentDms =>
      $$RecentDmsTableTableManager(_db, _db.recentDms);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
}
