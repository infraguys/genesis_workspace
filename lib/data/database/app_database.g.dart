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

class $OrganizationsTable extends Organizations
    with TableInfo<$OrganizationsTable, Organization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, name, icon, baseUrl, unreadCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organizations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Organization> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {baseUrl},
    {id},
  ];
  @override
  Organization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Organization(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
    );
  }

  @override
  $OrganizationsTable createAlias(String alias) {
    return $OrganizationsTable(attachedDatabase, alias);
  }
}

class Organization extends DataClass implements Insertable<Organization> {
  final int id;
  final String name;
  final String icon;
  final String baseUrl;
  final int unreadCount;
  const Organization({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUrl,
    required this.unreadCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['base_url'] = Variable<String>(baseUrl);
    map['unread_count'] = Variable<int>(unreadCount);
    return map;
  }

  OrganizationsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      baseUrl: Value(baseUrl),
      unreadCount: Value(unreadCount),
    );
  }

  factory Organization.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Organization(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'unreadCount': serializer.toJson<int>(unreadCount),
    };
  }

  Organization copyWith({
    int? id,
    String? name,
    String? icon,
    String? baseUrl,
    int? unreadCount,
  }) => Organization(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    baseUrl: baseUrl ?? this.baseUrl,
    unreadCount: unreadCount ?? this.unreadCount,
  );
  Organization copyWithCompanion(OrganizationsCompanion data) {
    return Organization(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Organization(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('unreadCount: $unreadCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, baseUrl, unreadCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Organization &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.baseUrl == this.baseUrl &&
          other.unreadCount == this.unreadCount);
}

class OrganizationsCompanion extends UpdateCompanion<Organization> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> baseUrl;
  final Value<int> unreadCount;
  const OrganizationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.unreadCount = const Value.absent(),
  });
  OrganizationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required String baseUrl,
    this.unreadCount = const Value.absent(),
  }) : name = Value(name),
       icon = Value(icon),
       baseUrl = Value(baseUrl);
  static Insertable<Organization> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? baseUrl,
    Expression<int>? unreadCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (baseUrl != null) 'base_url': baseUrl,
      if (unreadCount != null) 'unread_count': unreadCount,
    });
  }

  OrganizationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? baseUrl,
    Value<int>? unreadCount,
  }) {
    return OrganizationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      baseUrl: baseUrl ?? this.baseUrl,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('unreadCount: $unreadCount')
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
  static const VerificationMeta _systemTypeMeta = const VerificationMeta(
    'systemType',
  );
  @override
  late final GeneratedColumn<String> systemType = GeneratedColumn<String>(
    'system_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    iconCodePoint,
    backgroundColorValue,
    unreadCount,
    systemType,
    organizationId,
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
    if (data.containsKey('system_type')) {
      context.handle(
        _systemTypeMeta,
        systemType.isAcceptableOrUnknown(data['system_type']!, _systemTypeMeta),
      );
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
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
      systemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_type'],
      ),
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
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
  final String? systemType;
  final int organizationId;
  const Folder({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.backgroundColorValue,
    required this.unreadCount,
    this.systemType,
    required this.organizationId,
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
    if (!nullToAbsent || systemType != null) {
      map['system_type'] = Variable<String>(systemType);
    }
    map['organization_id'] = Variable<int>(organizationId);
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
      systemType: systemType == null && nullToAbsent
          ? const Value.absent()
          : Value(systemType),
      organizationId: Value(organizationId),
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
      systemType: serializer.fromJson<String?>(json['systemType']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
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
      'systemType': serializer.toJson<String?>(systemType),
      'organizationId': serializer.toJson<int>(organizationId),
    };
  }

  Folder copyWith({
    int? id,
    String? title,
    int? iconCodePoint,
    Value<int?> backgroundColorValue = const Value.absent(),
    int? unreadCount,
    Value<String?> systemType = const Value.absent(),
    int? organizationId,
  }) => Folder(
    id: id ?? this.id,
    title: title ?? this.title,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    backgroundColorValue: backgroundColorValue.present
        ? backgroundColorValue.value
        : this.backgroundColorValue,
    unreadCount: unreadCount ?? this.unreadCount,
    systemType: systemType.present ? systemType.value : this.systemType,
    organizationId: organizationId ?? this.organizationId,
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
      systemType: data.systemType.present
          ? data.systemType.value
          : this.systemType,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('backgroundColorValue: $backgroundColorValue, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('systemType: $systemType, ')
          ..write('organizationId: $organizationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    iconCodePoint,
    backgroundColorValue,
    unreadCount,
    systemType,
    organizationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.title == this.title &&
          other.iconCodePoint == this.iconCodePoint &&
          other.backgroundColorValue == this.backgroundColorValue &&
          other.unreadCount == this.unreadCount &&
          other.systemType == this.systemType &&
          other.organizationId == this.organizationId);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> iconCodePoint;
  final Value<int?> backgroundColorValue;
  final Value<int> unreadCount;
  final Value<String?> systemType;
  final Value<int> organizationId;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.backgroundColorValue = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.systemType = const Value.absent(),
    this.organizationId = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int iconCodePoint,
    this.backgroundColorValue = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.systemType = const Value.absent(),
    required int organizationId,
  }) : title = Value(title),
       iconCodePoint = Value(iconCodePoint),
       organizationId = Value(organizationId);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? iconCodePoint,
    Expression<int>? backgroundColorValue,
    Expression<int>? unreadCount,
    Expression<String>? systemType,
    Expression<int>? organizationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (backgroundColorValue != null)
        'background_color_value': backgroundColorValue,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (systemType != null) 'system_type': systemType,
      if (organizationId != null) 'organization_id': organizationId,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? iconCodePoint,
    Value<int?>? backgroundColorValue,
    Value<int>? unreadCount,
    Value<String?>? systemType,
    Value<int>? organizationId,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      unreadCount: unreadCount ?? this.unreadCount,
      systemType: systemType ?? this.systemType,
      organizationId: organizationId ?? this.organizationId,
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
    if (systemType.present) {
      map['system_type'] = Variable<String>(systemType.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
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
          ..write('unreadCount: $unreadCount, ')
          ..write('systemType: $systemType, ')
          ..write('organizationId: $organizationId')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id) ON DELETE CASCADE',
    ),
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
    organizationId,
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
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
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
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
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
  final int organizationId;
  final String itemType;
  final int targetId;
  final String? topicName;
  const FolderItem({
    required this.id,
    required this.folderId,
    required this.organizationId,
    required this.itemType,
    required this.targetId,
    this.topicName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folder_id'] = Variable<int>(folderId);
    map['organization_id'] = Variable<int>(organizationId);
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
      organizationId: Value(organizationId),
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
      organizationId: serializer.fromJson<int>(json['organizationId']),
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
      'organizationId': serializer.toJson<int>(organizationId),
      'itemType': serializer.toJson<String>(itemType),
      'targetId': serializer.toJson<int>(targetId),
      'topicName': serializer.toJson<String?>(topicName),
    };
  }

  FolderItem copyWith({
    int? id,
    int? folderId,
    int? organizationId,
    String? itemType,
    int? targetId,
    Value<String?> topicName = const Value.absent(),
  }) => FolderItem(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    organizationId: organizationId ?? this.organizationId,
    itemType: itemType ?? this.itemType,
    targetId: targetId ?? this.targetId,
    topicName: topicName.present ? topicName.value : this.topicName,
  );
  FolderItem copyWithCompanion(FolderItemsCompanion data) {
    return FolderItem(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
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
          ..write('organizationId: $organizationId, ')
          ..write('itemType: $itemType, ')
          ..write('targetId: $targetId, ')
          ..write('topicName: $topicName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, folderId, organizationId, itemType, targetId, topicName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderItem &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.organizationId == this.organizationId &&
          other.itemType == this.itemType &&
          other.targetId == this.targetId &&
          other.topicName == this.topicName);
}

class FolderItemsCompanion extends UpdateCompanion<FolderItem> {
  final Value<int> id;
  final Value<int> folderId;
  final Value<int> organizationId;
  final Value<String> itemType;
  final Value<int> targetId;
  final Value<String?> topicName;
  const FolderItemsCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.topicName = const Value.absent(),
  });
  FolderItemsCompanion.insert({
    this.id = const Value.absent(),
    required int folderId,
    required int organizationId,
    required String itemType,
    required int targetId,
    this.topicName = const Value.absent(),
  }) : folderId = Value(folderId),
       organizationId = Value(organizationId),
       itemType = Value(itemType),
       targetId = Value(targetId);
  static Insertable<FolderItem> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<int>? organizationId,
    Expression<String>? itemType,
    Expression<int>? targetId,
    Expression<String>? topicName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (organizationId != null) 'organization_id': organizationId,
      if (itemType != null) 'item_type': itemType,
      if (targetId != null) 'target_id': targetId,
      if (topicName != null) 'topic_name': topicName,
    });
  }

  FolderItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? folderId,
    Value<int>? organizationId,
    Value<String>? itemType,
    Value<int>? targetId,
    Value<String?>? topicName,
  }) {
    return FolderItemsCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      organizationId: organizationId ?? this.organizationId,
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
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
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
          ..write('organizationId: $organizationId, ')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE CASCADE',
    ),
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
  late final GeneratedColumnWithTypeConverter<PinnedChatType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PinnedChatType>($PinnedChatsTable.$convertertype);
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    orderIndex,
    chatId,
    pinnedAt,
    type,
    organizationId,
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
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
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
      type: $PinnedChatsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}organization_id'],
      )!,
    );
  }

  @override
  $PinnedChatsTable createAlias(String alias) {
    return $PinnedChatsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PinnedChatType, String, String> $convertertype =
      const EnumNameConverter<PinnedChatType>(PinnedChatType.values);
}

class PinnedChat extends DataClass implements Insertable<PinnedChat> {
  final int id;
  final int folderId;
  final int? orderIndex;
  final int chatId;
  final DateTime pinnedAt;
  final PinnedChatType type;
  final int organizationId;
  const PinnedChat({
    required this.id,
    required this.folderId,
    this.orderIndex,
    required this.chatId,
    required this.pinnedAt,
    required this.type,
    required this.organizationId,
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
    {
      map['type'] = Variable<String>(
        $PinnedChatsTable.$convertertype.toSql(type),
      );
    }
    map['organization_id'] = Variable<int>(organizationId);
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
      type: Value(type),
      organizationId: Value(organizationId),
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
      type: $PinnedChatsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      organizationId: serializer.fromJson<int>(json['organizationId']),
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
      'type': serializer.toJson<String>(
        $PinnedChatsTable.$convertertype.toJson(type),
      ),
      'organizationId': serializer.toJson<int>(organizationId),
    };
  }

  PinnedChat copyWith({
    int? id,
    int? folderId,
    Value<int?> orderIndex = const Value.absent(),
    int? chatId,
    DateTime? pinnedAt,
    PinnedChatType? type,
    int? organizationId,
  }) => PinnedChat(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    orderIndex: orderIndex.present ? orderIndex.value : this.orderIndex,
    chatId: chatId ?? this.chatId,
    pinnedAt: pinnedAt ?? this.pinnedAt,
    type: type ?? this.type,
    organizationId: organizationId ?? this.organizationId,
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
      type: data.type.present ? data.type.value : this.type,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedChat(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('chatId: $chatId, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('type: $type, ')
          ..write('organizationId: $organizationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    folderId,
    orderIndex,
    chatId,
    pinnedAt,
    type,
    organizationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedChat &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.orderIndex == this.orderIndex &&
          other.chatId == this.chatId &&
          other.pinnedAt == this.pinnedAt &&
          other.type == this.type &&
          other.organizationId == this.organizationId);
}

class PinnedChatsCompanion extends UpdateCompanion<PinnedChat> {
  final Value<int> id;
  final Value<int> folderId;
  final Value<int?> orderIndex;
  final Value<int> chatId;
  final Value<DateTime> pinnedAt;
  final Value<PinnedChatType> type;
  final Value<int> organizationId;
  const PinnedChatsCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.chatId = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.organizationId = const Value.absent(),
  });
  PinnedChatsCompanion.insert({
    this.id = const Value.absent(),
    required int folderId,
    this.orderIndex = const Value.absent(),
    required int chatId,
    this.pinnedAt = const Value.absent(),
    required PinnedChatType type,
    required int organizationId,
  }) : folderId = Value(folderId),
       chatId = Value(chatId),
       type = Value(type),
       organizationId = Value(organizationId);
  static Insertable<PinnedChat> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<int>? orderIndex,
    Expression<int>? chatId,
    Expression<DateTime>? pinnedAt,
    Expression<String>? type,
    Expression<int>? organizationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (chatId != null) 'chat_id': chatId,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
      if (type != null) 'type': type,
      if (organizationId != null) 'organization_id': organizationId,
    });
  }

  PinnedChatsCompanion copyWith({
    Value<int>? id,
    Value<int>? folderId,
    Value<int?>? orderIndex,
    Value<int>? chatId,
    Value<DateTime>? pinnedAt,
    Value<PinnedChatType>? type,
    Value<int>? organizationId,
  }) {
    return PinnedChatsCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      orderIndex: orderIndex ?? this.orderIndex,
      chatId: chatId ?? this.chatId,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      type: type ?? this.type,
      organizationId: organizationId ?? this.organizationId,
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
    if (type.present) {
      map['type'] = Variable<String>(
        $PinnedChatsTable.$convertertype.toSql(type.value),
      );
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
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
          ..write('pinnedAt: $pinnedAt, ')
          ..write('type: $type, ')
          ..write('organizationId: $organizationId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentDmsTable recentDms = $RecentDmsTable(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $FolderItemsTable folderItems = $FolderItemsTable(this);
  late final $PinnedChatsTable pinnedChats = $PinnedChatsTable(this);
  late final RecentDmDao recentDmDao = RecentDmDao(this as AppDatabase);
  late final FolderDao folderDao = FolderDao(this as AppDatabase);
  late final FolderItemDao folderItemDao = FolderItemDao(this as AppDatabase);
  late final PinnedChatsDao pinnedChatsDao = PinnedChatsDao(
    this as AppDatabase,
  );
  late final OrganizationsDao organizationsDao = OrganizationsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recentDms,
    organizations,
    folders,
    folderItems,
    pinnedChats,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'organizations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('folders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('folder_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'organizations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('folder_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pinned_chats', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'organizations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pinned_chats', kind: UpdateKind.delete)],
    ),
  ]);
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
typedef $$OrganizationsTableCreateCompanionBuilder =
    OrganizationsCompanion Function({
      Value<int> id,
      required String name,
      required String icon,
      required String baseUrl,
      Value<int> unreadCount,
    });
typedef $$OrganizationsTableUpdateCompanionBuilder =
    OrganizationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<String> baseUrl,
      Value<int> unreadCount,
    });

final class $$OrganizationsTableReferences
    extends BaseReferences<_$AppDatabase, $OrganizationsTable, Organization> {
  $$OrganizationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$FoldersTable, List<Folder>> _foldersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.folders,
    aliasName: $_aliasNameGenerator(
      db.organizations.id,
      db.folders.organizationId,
    ),
  );

  $$FoldersTableProcessedTableManager get foldersRefs {
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_foldersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FolderItemsTable, List<FolderItem>>
  _folderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.folderItems,
    aliasName: $_aliasNameGenerator(
      db.organizations.id,
      db.folderItems.organizationId,
    ),
  );

  $$FolderItemsTableProcessedTableManager get folderItemsRefs {
    final manager = $$FolderItemsTableTableManager(
      $_db,
      $_db.folderItems,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_folderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PinnedChatsTable, List<PinnedChat>>
  _pinnedChatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pinnedChats,
    aliasName: $_aliasNameGenerator(
      db.organizations.id,
      db.pinnedChats.organizationId,
    ),
  );

  $$PinnedChatsTableProcessedTableManager get pinnedChatsRefs {
    final manager = $$PinnedChatsTableTableManager(
      $_db,
      $_db.pinnedChats,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pinnedChatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> foldersRefs(
    Expression<bool> Function($$FoldersTableFilterComposer f) f,
  ) {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> folderItemsRefs(
    Expression<bool> Function($$FolderItemsTableFilterComposer f) f,
  ) {
    final $$FolderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.folderItems,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FolderItemsTableFilterComposer(
            $db: $db,
            $table: $db.folderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pinnedChatsRefs(
    Expression<bool> Function($$PinnedChatsTableFilterComposer f) f,
  ) {
    final $$PinnedChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinnedChats,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinnedChatsTableFilterComposer(
            $db: $db,
            $table: $db.pinnedChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  Expression<T> foldersRefs<T extends Object>(
    Expression<T> Function($$FoldersTableAnnotationComposer a) f,
  ) {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> folderItemsRefs<T extends Object>(
    Expression<T> Function($$FolderItemsTableAnnotationComposer a) f,
  ) {
    final $$FolderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.folderItems,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FolderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.folderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pinnedChatsRefs<T extends Object>(
    Expression<T> Function($$PinnedChatsTableAnnotationComposer a) f,
  ) {
    final $$PinnedChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinnedChats,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinnedChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.pinnedChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrganizationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrganizationsTable,
          Organization,
          $$OrganizationsTableFilterComposer,
          $$OrganizationsTableOrderingComposer,
          $$OrganizationsTableAnnotationComposer,
          $$OrganizationsTableCreateCompanionBuilder,
          $$OrganizationsTableUpdateCompanionBuilder,
          (Organization, $$OrganizationsTableReferences),
          Organization,
          PrefetchHooks Function({
            bool foldersRefs,
            bool folderItemsRefs,
            bool pinnedChatsRefs,
          })
        > {
  $$OrganizationsTableTableManager(_$AppDatabase db, $OrganizationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
              }) => OrganizationsCompanion(
                id: id,
                name: name,
                icon: icon,
                baseUrl: baseUrl,
                unreadCount: unreadCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String icon,
                required String baseUrl,
                Value<int> unreadCount = const Value.absent(),
              }) => OrganizationsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                baseUrl: baseUrl,
                unreadCount: unreadCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrganizationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                foldersRefs = false,
                folderItemsRefs = false,
                pinnedChatsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (foldersRefs) db.folders,
                    if (folderItemsRefs) db.folderItems,
                    if (pinnedChatsRefs) db.pinnedChats,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (foldersRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          Folder
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._foldersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).foldersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (folderItemsRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          FolderItem
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._folderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).folderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pinnedChatsRefs)
                        await $_getPrefetchedData<
                          Organization,
                          $OrganizationsTable,
                          PinnedChat
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._pinnedChatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).pinnedChatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrganizationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrganizationsTable,
      Organization,
      $$OrganizationsTableFilterComposer,
      $$OrganizationsTableOrderingComposer,
      $$OrganizationsTableAnnotationComposer,
      $$OrganizationsTableCreateCompanionBuilder,
      $$OrganizationsTableUpdateCompanionBuilder,
      (Organization, $$OrganizationsTableReferences),
      Organization,
      PrefetchHooks Function({
        bool foldersRefs,
        bool folderItemsRefs,
        bool pinnedChatsRefs,
      })
    >;
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      required String title,
      required int iconCodePoint,
      Value<int?> backgroundColorValue,
      Value<int> unreadCount,
      Value<String?> systemType,
      required int organizationId,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> iconCodePoint,
      Value<int?> backgroundColorValue,
      Value<int> unreadCount,
      Value<String?> systemType,
      Value<int> organizationId,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(db.folders.organizationId, db.organizations.id),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FolderItemsTable, List<FolderItem>>
  _folderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.folderItems,
    aliasName: $_aliasNameGenerator(db.folders.id, db.folderItems.folderId),
  );

  $$FolderItemsTableProcessedTableManager get folderItemsRefs {
    final manager = $$FolderItemsTableTableManager(
      $_db,
      $_db.folderItems,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_folderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PinnedChatsTable, List<PinnedChat>>
  _pinnedChatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pinnedChats,
    aliasName: $_aliasNameGenerator(db.folders.id, db.pinnedChats.folderId),
  );

  $$PinnedChatsTableProcessedTableManager get pinnedChatsRefs {
    final manager = $$PinnedChatsTableTableManager(
      $_db,
      $_db.pinnedChats,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pinnedChatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> folderItemsRefs(
    Expression<bool> Function($$FolderItemsTableFilterComposer f) f,
  ) {
    final $$FolderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.folderItems,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FolderItemsTableFilterComposer(
            $db: $db,
            $table: $db.folderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pinnedChatsRefs(
    Expression<bool> Function($$PinnedChatsTableFilterComposer f) f,
  ) {
    final $$PinnedChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinnedChats,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinnedChatsTableFilterComposer(
            $db: $db,
            $table: $db.pinnedChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => column,
  );

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> folderItemsRefs<T extends Object>(
    Expression<T> Function($$FolderItemsTableAnnotationComposer a) f,
  ) {
    final $$FolderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.folderItems,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FolderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.folderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pinnedChatsRefs<T extends Object>(
    Expression<T> Function($$PinnedChatsTableAnnotationComposer a) f,
  ) {
    final $$PinnedChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pinnedChats,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PinnedChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.pinnedChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({
            bool organizationId,
            bool folderItemsRefs,
            bool pinnedChatsRefs,
          })
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
                Value<String?> systemType = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                title: title,
                iconCodePoint: iconCodePoint,
                backgroundColorValue: backgroundColorValue,
                unreadCount: unreadCount,
                systemType: systemType,
                organizationId: organizationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int iconCodePoint,
                Value<int?> backgroundColorValue = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> systemType = const Value.absent(),
                required int organizationId,
              }) => FoldersCompanion.insert(
                id: id,
                title: title,
                iconCodePoint: iconCodePoint,
                backgroundColorValue: backgroundColorValue,
                unreadCount: unreadCount,
                systemType: systemType,
                organizationId: organizationId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                organizationId = false,
                folderItemsRefs = false,
                pinnedChatsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (folderItemsRefs) db.folderItems,
                    if (pinnedChatsRefs) db.pinnedChats,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (organizationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.organizationId,
                                    referencedTable: $$FoldersTableReferences
                                        ._organizationIdTable(db),
                                    referencedColumn: $$FoldersTableReferences
                                        ._organizationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (folderItemsRefs)
                        await $_getPrefetchedData<
                          Folder,
                          $FoldersTable,
                          FolderItem
                        >(
                          currentTable: table,
                          referencedTable: $$FoldersTableReferences
                              ._folderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoldersTableReferences(
                                db,
                                table,
                                p0,
                              ).folderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.folderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pinnedChatsRefs)
                        await $_getPrefetchedData<
                          Folder,
                          $FoldersTable,
                          PinnedChat
                        >(
                          currentTable: table,
                          referencedTable: $$FoldersTableReferences
                              ._pinnedChatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoldersTableReferences(
                                db,
                                table,
                                p0,
                              ).pinnedChatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.folderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({
        bool organizationId,
        bool folderItemsRefs,
        bool pinnedChatsRefs,
      })
    >;
typedef $$FolderItemsTableCreateCompanionBuilder =
    FolderItemsCompanion Function({
      Value<int> id,
      required int folderId,
      required int organizationId,
      required String itemType,
      required int targetId,
      Value<String?> topicName,
    });
typedef $$FolderItemsTableUpdateCompanionBuilder =
    FolderItemsCompanion Function({
      Value<int> id,
      Value<int> folderId,
      Value<int> organizationId,
      Value<String> itemType,
      Value<int> targetId,
      Value<String?> topicName,
    });

final class $$FolderItemsTableReferences
    extends BaseReferences<_$AppDatabase, $FolderItemsTable, FolderItem> {
  $$FolderItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias(
        $_aliasNameGenerator(db.folderItems.folderId, db.folders.id),
      );

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.folderItems.organizationId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get topicName =>
      $composableBuilder(column: $table.topicName, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (FolderItem, $$FolderItemsTableReferences),
          FolderItem,
          PrefetchHooks Function({bool folderId, bool organizationId})
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
                Value<int> organizationId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> targetId = const Value.absent(),
                Value<String?> topicName = const Value.absent(),
              }) => FolderItemsCompanion(
                id: id,
                folderId: folderId,
                organizationId: organizationId,
                itemType: itemType,
                targetId: targetId,
                topicName: topicName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int folderId,
                required int organizationId,
                required String itemType,
                required int targetId,
                Value<String?> topicName = const Value.absent(),
              }) => FolderItemsCompanion.insert(
                id: id,
                folderId: folderId,
                organizationId: organizationId,
                itemType: itemType,
                targetId: targetId,
                topicName: topicName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FolderItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, organizationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$FolderItemsTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$FolderItemsTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (organizationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.organizationId,
                                referencedTable: $$FolderItemsTableReferences
                                    ._organizationIdTable(db),
                                referencedColumn: $$FolderItemsTableReferences
                                    ._organizationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (FolderItem, $$FolderItemsTableReferences),
      FolderItem,
      PrefetchHooks Function({bool folderId, bool organizationId})
    >;
typedef $$PinnedChatsTableCreateCompanionBuilder =
    PinnedChatsCompanion Function({
      Value<int> id,
      required int folderId,
      Value<int?> orderIndex,
      required int chatId,
      Value<DateTime> pinnedAt,
      required PinnedChatType type,
      required int organizationId,
    });
typedef $$PinnedChatsTableUpdateCompanionBuilder =
    PinnedChatsCompanion Function({
      Value<int> id,
      Value<int> folderId,
      Value<int?> orderIndex,
      Value<int> chatId,
      Value<DateTime> pinnedAt,
      Value<PinnedChatType> type,
      Value<int> organizationId,
    });

final class $$PinnedChatsTableReferences
    extends BaseReferences<_$AppDatabase, $PinnedChatsTable, PinnedChat> {
  $$PinnedChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias(
        $_aliasNameGenerator(db.pinnedChats.folderId, db.folders.id),
      );

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
        $_aliasNameGenerator(
          db.pinnedChats.organizationId,
          db.organizations.id,
        ),
      );

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  ColumnWithTypeConverterFilters<PinnedChatType, PinnedChatType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<DateTime> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PinnedChatType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (PinnedChat, $$PinnedChatsTableReferences),
          PinnedChat,
          PrefetchHooks Function({bool folderId, bool organizationId})
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
                Value<PinnedChatType> type = const Value.absent(),
                Value<int> organizationId = const Value.absent(),
              }) => PinnedChatsCompanion(
                id: id,
                folderId: folderId,
                orderIndex: orderIndex,
                chatId: chatId,
                pinnedAt: pinnedAt,
                type: type,
                organizationId: organizationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int folderId,
                Value<int?> orderIndex = const Value.absent(),
                required int chatId,
                Value<DateTime> pinnedAt = const Value.absent(),
                required PinnedChatType type,
                required int organizationId,
              }) => PinnedChatsCompanion.insert(
                id: id,
                folderId: folderId,
                orderIndex: orderIndex,
                chatId: chatId,
                pinnedAt: pinnedAt,
                type: type,
                organizationId: organizationId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PinnedChatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, organizationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$PinnedChatsTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$PinnedChatsTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (organizationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.organizationId,
                                referencedTable: $$PinnedChatsTableReferences
                                    ._organizationIdTable(db),
                                referencedColumn: $$PinnedChatsTableReferences
                                    ._organizationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (PinnedChat, $$PinnedChatsTableReferences),
      PinnedChat,
      PrefetchHooks Function({bool folderId, bool organizationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentDmsTableTableManager get recentDms =>
      $$RecentDmsTableTableManager(_db, _db.recentDms);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$FolderItemsTableTableManager get folderItems =>
      $$FolderItemsTableTableManager(_db, _db.folderItems);
  $$PinnedChatsTableTableManager get pinnedChats =>
      $$PinnedChatsTableTableManager(_db, _db.pinnedChats);
}
