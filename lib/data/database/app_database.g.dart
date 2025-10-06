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

class $FolderItemsTable extends FolderItems
    with TableInfo<$FolderItemsTable, FolderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicNameMeta = const VerificationMeta(
    'topicName',
  );
  @override
  late final GeneratedColumn<String> topicName = GeneratedColumn<String>(
    'topic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    itemType,
    targetId,
    topicName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FolderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('topic_name')) {
      context.handle(
        _topicNameMeta,
        topicName.isAcceptableOrUnknown(data['topic_name']!, _topicNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FolderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      )!,
      topicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_name'],
      ),
    );
  }

  @override
  $FolderItemsTable createAlias(String alias) {
    return $FolderItemsTable(attachedDatabase, alias);
  }
}

class FolderItem extends DataClass implements Insertable<FolderItem> {
  final int id;
  final int folderId;
  final String itemType;
  final int targetId;
  final String? topicName;
  const FolderItem({
    required this.id,
    required this.folderId,
    required this.itemType,
    required this.targetId,
    this.topicName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folder_id'] = Variable<int>(folderId);
    map['item_type'] = Variable<String>(itemType);
    map['target_id'] = Variable<int>(targetId);
    if (!nullToAbsent || topicName != null) {
      map['topic_name'] = Variable<String>(topicName);
    }
    return map;
  }

  FolderItemsCompanion toCompanion(bool nullToAbsent) {
    return FolderItemsCompanion(
      id: Value(id),
      folderId: Value(folderId),
      itemType: Value(itemType),
      targetId: Value(targetId),
      topicName: topicName == null && nullToAbsent
          ? const Value.absent()
          : Value(topicName),
    );
  }

  factory FolderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderItem(
      id: serializer.fromJson<int>(json['id']),
      folderId: serializer.fromJson<int>(json['folderId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      targetId: serializer.fromJson<int>(json['targetId']),
      topicName: serializer.fromJson<String?>(json['topicName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folderId': serializer.toJson<int>(folderId),
      'itemType': serializer.toJson<String>(itemType),
      'targetId': serializer.toJson<int>(targetId),
      'topicName': serializer.toJson<String?>(topicName),
    };
  }

  FolderItem copyWith({
    int? id,
    int? folderId,
    String? itemType,
    int? targetId,
    Value<String?> topicName = const Value.absent(),
  }) => FolderItem(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    itemType: itemType ?? this.itemType,
    targetId: targetId ?? this.targetId,
    topicName: topicName.present ? topicName.value : this.topicName,
  );
  FolderItem copyWithCompanion(FolderItemsCompanion data) {
    return FolderItem(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      topicName: data.topicName.present ? data.topicName.value : this.topicName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderItem(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('itemType: $itemType, ')
          ..write('targetId: $targetId, ')
          ..write('topicName: $topicName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, folderId, itemType, targetId, topicName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderItem &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.itemType == this.itemType &&
          other.targetId == this.targetId &&
          other.topicName == this.topicName);
}

class FolderItemsCompanion extends UpdateCompanion<FolderItem> {
  final Value<int> id;
  final Value<int> folderId;
  final Value<String> itemType;
  final Value<int> targetId;
  final Value<String?> topicName;
  const FolderItemsCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.topicName = const Value.absent(),
  });
  FolderItemsCompanion.insert({
    this.id = const Value.absent(),
    required int folderId,
    required String itemType,
    required int targetId,
    this.topicName = const Value.absent(),
  }) : folderId = Value(folderId),
       itemType = Value(itemType),
       targetId = Value(targetId);
  static Insertable<FolderItem> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<String>? itemType,
    Expression<int>? targetId,
    Expression<String>? topicName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (itemType != null) 'item_type': itemType,
      if (targetId != null) 'target_id': targetId,
      if (topicName != null) 'topic_name': topicName,
    });
  }

  FolderItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? folderId,
    Value<String>? itemType,
    Value<int>? targetId,
    Value<String?>? topicName,
  }) {
    return FolderItemsCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      itemType: itemType ?? this.itemType,
      targetId: targetId ?? this.targetId,
      topicName: topicName ?? this.topicName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    if (topicName.present) {
      map['topic_name'] = Variable<String>(topicName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderItemsCompanion(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('itemType: $itemType, ')
          ..write('targetId: $targetId, ')
          ..write('topicName: $topicName')
          ..write(')'))
        .toString();
  }
}

class $PinnedChatsTable extends PinnedChats
    with TableInfo<$PinnedChatsTable, PinnedChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinnedChatsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES folders(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedAtMeta = const VerificationMeta(
    'pinnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pinnedAt = GeneratedColumn<DateTime>(
    'pinned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    orderIndex,
    chatId,
    pinnedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinned_chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<PinnedChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('pinned_at')) {
      context.handle(
        _pinnedAtMeta,
        pinnedAt.isAcceptableOrUnknown(data['pinned_at']!, _pinnedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {folderId, chatId},
  ];
  @override
  PinnedChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedChat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      ),
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      pinnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pinned_at'],
      )!,
    );
  }

  @override
  $PinnedChatsTable createAlias(String alias) {
    return $PinnedChatsTable(attachedDatabase, alias);
  }
}

class PinnedChat extends DataClass implements Insertable<PinnedChat> {
  final int id;
  final int folderId;
  final int? orderIndex;
  final int chatId;
  final DateTime pinnedAt;
  const PinnedChat({
    required this.id,
    required this.folderId,
    this.orderIndex,
    required this.chatId,
    required this.pinnedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folder_id'] = Variable<int>(folderId);
    if (!nullToAbsent || orderIndex != null) {
      map['order_index'] = Variable<int>(orderIndex);
    }
    map['chat_id'] = Variable<int>(chatId);
    map['pinned_at'] = Variable<DateTime>(pinnedAt);
    return map;
  }

  PinnedChatsCompanion toCompanion(bool nullToAbsent) {
    return PinnedChatsCompanion(
      id: Value(id),
      folderId: Value(folderId),
      orderIndex: orderIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(orderIndex),
      chatId: Value(chatId),
      pinnedAt: Value(pinnedAt),
    );
  }

  factory PinnedChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedChat(
      id: serializer.fromJson<int>(json['id']),
      folderId: serializer.fromJson<int>(json['folderId']),
      orderIndex: serializer.fromJson<int?>(json['orderIndex']),
      chatId: serializer.fromJson<int>(json['chatId']),
      pinnedAt: serializer.fromJson<DateTime>(json['pinnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folderId': serializer.toJson<int>(folderId),
      'orderIndex': serializer.toJson<int?>(orderIndex),
      'chatId': serializer.toJson<int>(chatId),
      'pinnedAt': serializer.toJson<DateTime>(pinnedAt),
    };
  }

  PinnedChat copyWith({
    int? id,
    int? folderId,
    Value<int?> orderIndex = const Value.absent(),
    int? chatId,
    DateTime? pinnedAt,
  }) => PinnedChat(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    orderIndex: orderIndex.present ? orderIndex.value : this.orderIndex,
    chatId: chatId ?? this.chatId,
    pinnedAt: pinnedAt ?? this.pinnedAt,
  );
  PinnedChat copyWithCompanion(PinnedChatsCompanion data) {
    return PinnedChat(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      pinnedAt: data.pinnedAt.present ? data.pinnedAt.value : this.pinnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedChat(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('chatId: $chatId, ')
          ..write('pinnedAt: $pinnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, folderId, orderIndex, chatId, pinnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedChat &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.orderIndex == this.orderIndex &&
          other.chatId == this.chatId &&
          other.pinnedAt == this.pinnedAt);
}

class PinnedChatsCompanion extends UpdateCompanion<PinnedChat> {
  final Value<int> id;
  final Value<int> folderId;
  final Value<int?> orderIndex;
  final Value<int> chatId;
  final Value<DateTime> pinnedAt;
  const PinnedChatsCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.chatId = const Value.absent(),
    this.pinnedAt = const Value.absent(),
  });
  PinnedChatsCompanion.insert({
    this.id = const Value.absent(),
    required int folderId,
    this.orderIndex = const Value.absent(),
    required int chatId,
    this.pinnedAt = const Value.absent(),
  }) : folderId = Value(folderId),
       chatId = Value(chatId);
  static Insertable<PinnedChat> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<int>? orderIndex,
    Expression<int>? chatId,
    Expression<DateTime>? pinnedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (chatId != null) 'chat_id': chatId,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
    });
  }

  PinnedChatsCompanion copyWith({
    Value<int>? id,
    Value<int>? folderId,
    Value<int?>? orderIndex,
    Value<int>? chatId,
    Value<DateTime>? pinnedAt,
  }) {
    return PinnedChatsCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      orderIndex: orderIndex ?? this.orderIndex,
      chatId: chatId ?? this.chatId,
      pinnedAt: pinnedAt ?? this.pinnedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (pinnedAt.present) {
      map['pinned_at'] = Variable<DateTime>(pinnedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedChatsCompanion(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('chatId: $chatId, ')
          ..write('pinnedAt: $pinnedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentDmsTable recentDms = $RecentDmsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $FolderItemsTable folderItems = $FolderItemsTable(this);
  late final $PinnedChatsTable pinnedChats = $PinnedChatsTable(this);
  late final RecentDmDao recentDmDao = RecentDmDao(this as AppDatabase);
  late final FolderDao folderDao = FolderDao(this as AppDatabase);
  late final FolderItemDao folderItemDao = FolderItemDao(this as AppDatabase);
  late final PinnedChatsDao pinnedChatsDao = PinnedChatsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recentDms,
    folders,
    folderItems,
    pinnedChats,
  ];
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
typedef $$FolderItemsTableCreateCompanionBuilder =
    FolderItemsCompanion Function({
      Value<int> id,
      required int folderId,
      required String itemType,
      required int targetId,
      Value<String?> topicName,
    });
typedef $$FolderItemsTableUpdateCompanionBuilder =
    FolderItemsCompanion Function({
      Value<int> id,
      Value<int> folderId,
      Value<String> itemType,
      Value<int> targetId,
      Value<String?> topicName,
    });

class $$FolderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FolderItemsTable> {
  $$FolderItemsTableFilterComposer({
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

  ColumnFilters<int> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicName => $composableBuilder(
    column: $table.topicName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FolderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FolderItemsTable> {
  $$FolderItemsTableOrderingComposer({
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

  ColumnOrderings<int> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicName => $composableBuilder(
    column: $table.topicName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FolderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FolderItemsTable> {
  $$FolderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get topicName =>
      $composableBuilder(column: $table.topicName, builder: (column) => column);
}

class $$FolderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FolderItemsTable,
          FolderItem,
          $$FolderItemsTableFilterComposer,
          $$FolderItemsTableOrderingComposer,
          $$FolderItemsTableAnnotationComposer,
          $$FolderItemsTableCreateCompanionBuilder,
          $$FolderItemsTableUpdateCompanionBuilder,
          (
            FolderItem,
            BaseReferences<_$AppDatabase, $FolderItemsTable, FolderItem>,
          ),
          FolderItem,
          PrefetchHooks Function()
        > {
  $$FolderItemsTableTableManager(_$AppDatabase db, $FolderItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FolderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FolderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FolderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> targetId = const Value.absent(),
                Value<String?> topicName = const Value.absent(),
              }) => FolderItemsCompanion(
                id: id,
                folderId: folderId,
                itemType: itemType,
                targetId: targetId,
                topicName: topicName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int folderId,
                required String itemType,
                required int targetId,
                Value<String?> topicName = const Value.absent(),
              }) => FolderItemsCompanion.insert(
                id: id,
                folderId: folderId,
                itemType: itemType,
                targetId: targetId,
                topicName: topicName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FolderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FolderItemsTable,
      FolderItem,
      $$FolderItemsTableFilterComposer,
      $$FolderItemsTableOrderingComposer,
      $$FolderItemsTableAnnotationComposer,
      $$FolderItemsTableCreateCompanionBuilder,
      $$FolderItemsTableUpdateCompanionBuilder,
      (
        FolderItem,
        BaseReferences<_$AppDatabase, $FolderItemsTable, FolderItem>,
      ),
      FolderItem,
      PrefetchHooks Function()
    >;
typedef $$PinnedChatsTableCreateCompanionBuilder =
    PinnedChatsCompanion Function({
      Value<int> id,
      required int folderId,
      Value<int?> orderIndex,
      required int chatId,
      Value<DateTime> pinnedAt,
    });
typedef $$PinnedChatsTableUpdateCompanionBuilder =
    PinnedChatsCompanion Function({
      Value<int> id,
      Value<int> folderId,
      Value<int?> orderIndex,
      Value<int> chatId,
      Value<DateTime> pinnedAt,
    });

class $$PinnedChatsTableFilterComposer
    extends Composer<_$AppDatabase, $PinnedChatsTable> {
  $$PinnedChatsTableFilterComposer({
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

  ColumnFilters<int> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PinnedChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $PinnedChatsTable> {
  $$PinnedChatsTableOrderingComposer({
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

  ColumnOrderings<int> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PinnedChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PinnedChatsTable> {
  $$PinnedChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<DateTime> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);
}

class $$PinnedChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PinnedChatsTable,
          PinnedChat,
          $$PinnedChatsTableFilterComposer,
          $$PinnedChatsTableOrderingComposer,
          $$PinnedChatsTableAnnotationComposer,
          $$PinnedChatsTableCreateCompanionBuilder,
          $$PinnedChatsTableUpdateCompanionBuilder,
          (
            PinnedChat,
            BaseReferences<_$AppDatabase, $PinnedChatsTable, PinnedChat>,
          ),
          PinnedChat,
          PrefetchHooks Function()
        > {
  $$PinnedChatsTableTableManager(_$AppDatabase db, $PinnedChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinnedChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinnedChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinnedChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<int?> orderIndex = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<DateTime> pinnedAt = const Value.absent(),
              }) => PinnedChatsCompanion(
                id: id,
                folderId: folderId,
                orderIndex: orderIndex,
                chatId: chatId,
                pinnedAt: pinnedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int folderId,
                Value<int?> orderIndex = const Value.absent(),
                required int chatId,
                Value<DateTime> pinnedAt = const Value.absent(),
              }) => PinnedChatsCompanion.insert(
                id: id,
                folderId: folderId,
                orderIndex: orderIndex,
                chatId: chatId,
                pinnedAt: pinnedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PinnedChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PinnedChatsTable,
      PinnedChat,
      $$PinnedChatsTableFilterComposer,
      $$PinnedChatsTableOrderingComposer,
      $$PinnedChatsTableAnnotationComposer,
      $$PinnedChatsTableCreateCompanionBuilder,
      $$PinnedChatsTableUpdateCompanionBuilder,
      (
        PinnedChat,
        BaseReferences<_$AppDatabase, $PinnedChatsTable, PinnedChat>,
      ),
      PinnedChat,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentDmsTableTableManager get recentDms =>
      $$RecentDmsTableTableManager(_db, _db.recentDms);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$FolderItemsTableTableManager get folderItems =>
      $$FolderItemsTableTableManager(_db, _db.folderItems);
  $$PinnedChatsTableTableManager get pinnedChats =>
      $$PinnedChatsTableTableManager(_db, _db.pinnedChats);
}
