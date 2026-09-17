// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ReadingPlansTable extends ReadingPlans
    with TableInfo<$ReadingPlansTable, ReadingPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingPlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _scopeCodeMeta = const VerificationMeta(
    'scopeCode',
  );
  @override
  late final GeneratedColumn<String> scopeCode = GeneratedColumn<String>(
    'scope_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDaysMeta = const VerificationMeta(
    'targetDays',
  );
  @override
  late final GeneratedColumn<int> targetDays = GeneratedColumn<int>(
    'target_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startEpochDayMeta = const VerificationMeta(
    'startEpochDay',
  );
  @override
  late final GeneratedColumn<int> startEpochDay = GeneratedColumn<int>(
    'start_epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scopeCode,
    targetDays,
    startEpochDay,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scope_code')) {
      context.handle(
        _scopeCodeMeta,
        scopeCode.isAcceptableOrUnknown(data['scope_code']!, _scopeCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeCodeMeta);
    }
    if (data.containsKey('target_days')) {
      context.handle(
        _targetDaysMeta,
        targetDays.isAcceptableOrUnknown(data['target_days']!, _targetDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDaysMeta);
    }
    if (data.containsKey('start_epoch_day')) {
      context.handle(
        _startEpochDayMeta,
        startEpochDay.isAcceptableOrUnknown(
          data['start_epoch_day']!,
          _startEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startEpochDayMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scopeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_code'],
      )!,
      targetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_days'],
      )!,
      startEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_epoch_day'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReadingPlansTable createAlias(String alias) {
    return $ReadingPlansTable(attachedDatabase, alias);
  }
}

class ReadingPlan extends DataClass implements Insertable<ReadingPlan> {
  final int id;
  final String scopeCode;
  final int targetDays;
  final int startEpochDay;
  final bool isActive;
  final DateTime createdAt;
  const ReadingPlan({
    required this.id,
    required this.scopeCode,
    required this.targetDays,
    required this.startEpochDay,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scope_code'] = Variable<String>(scopeCode);
    map['target_days'] = Variable<int>(targetDays);
    map['start_epoch_day'] = Variable<int>(startEpochDay);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReadingPlansCompanion toCompanion(bool nullToAbsent) {
    return ReadingPlansCompanion(
      id: Value(id),
      scopeCode: Value(scopeCode),
      targetDays: Value(targetDays),
      startEpochDay: Value(startEpochDay),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory ReadingPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPlan(
      id: serializer.fromJson<int>(json['id']),
      scopeCode: serializer.fromJson<String>(json['scopeCode']),
      targetDays: serializer.fromJson<int>(json['targetDays']),
      startEpochDay: serializer.fromJson<int>(json['startEpochDay']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scopeCode': serializer.toJson<String>(scopeCode),
      'targetDays': serializer.toJson<int>(targetDays),
      'startEpochDay': serializer.toJson<int>(startEpochDay),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReadingPlan copyWith({
    int? id,
    String? scopeCode,
    int? targetDays,
    int? startEpochDay,
    bool? isActive,
    DateTime? createdAt,
  }) => ReadingPlan(
    id: id ?? this.id,
    scopeCode: scopeCode ?? this.scopeCode,
    targetDays: targetDays ?? this.targetDays,
    startEpochDay: startEpochDay ?? this.startEpochDay,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  ReadingPlan copyWithCompanion(ReadingPlansCompanion data) {
    return ReadingPlan(
      id: data.id.present ? data.id.value : this.id,
      scopeCode: data.scopeCode.present ? data.scopeCode.value : this.scopeCode,
      targetDays: data.targetDays.present
          ? data.targetDays.value
          : this.targetDays,
      startEpochDay: data.startEpochDay.present
          ? data.startEpochDay.value
          : this.startEpochDay,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPlan(')
          ..write('id: $id, ')
          ..write('scopeCode: $scopeCode, ')
          ..write('targetDays: $targetDays, ')
          ..write('startEpochDay: $startEpochDay, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scopeCode,
    targetDays,
    startEpochDay,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPlan &&
          other.id == this.id &&
          other.scopeCode == this.scopeCode &&
          other.targetDays == this.targetDays &&
          other.startEpochDay == this.startEpochDay &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ReadingPlansCompanion extends UpdateCompanion<ReadingPlan> {
  final Value<int> id;
  final Value<String> scopeCode;
  final Value<int> targetDays;
  final Value<int> startEpochDay;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const ReadingPlansCompanion({
    this.id = const Value.absent(),
    this.scopeCode = const Value.absent(),
    this.targetDays = const Value.absent(),
    this.startEpochDay = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReadingPlansCompanion.insert({
    this.id = const Value.absent(),
    required String scopeCode,
    required int targetDays,
    required int startEpochDay,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : scopeCode = Value(scopeCode),
       targetDays = Value(targetDays),
       startEpochDay = Value(startEpochDay),
       createdAt = Value(createdAt);
  static Insertable<ReadingPlan> custom({
    Expression<int>? id,
    Expression<String>? scopeCode,
    Expression<int>? targetDays,
    Expression<int>? startEpochDay,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scopeCode != null) 'scope_code': scopeCode,
      if (targetDays != null) 'target_days': targetDays,
      if (startEpochDay != null) 'start_epoch_day': startEpochDay,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReadingPlansCompanion copyWith({
    Value<int>? id,
    Value<String>? scopeCode,
    Value<int>? targetDays,
    Value<int>? startEpochDay,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return ReadingPlansCompanion(
      id: id ?? this.id,
      scopeCode: scopeCode ?? this.scopeCode,
      targetDays: targetDays ?? this.targetDays,
      startEpochDay: startEpochDay ?? this.startEpochDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scopeCode.present) {
      map['scope_code'] = Variable<String>(scopeCode.value);
    }
    if (targetDays.present) {
      map['target_days'] = Variable<int>(targetDays.value);
    }
    if (startEpochDay.present) {
      map['start_epoch_day'] = Variable<int>(startEpochDay.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPlansCompanion(')
          ..write('id: $id, ')
          ..write('scopeCode: $scopeCode, ')
          ..write('targetDays: $targetDays, ')
          ..write('startEpochDay: $startEpochDay, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DayCompletionsTable extends DayCompletions
    with TableInfo<$DayCompletionsTable, DayCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedOnEpochDayMeta =
      const VerificationMeta('completedOnEpochDay');
  @override
  late final GeneratedColumn<int> completedOnEpochDay = GeneratedColumn<int>(
    'completed_on_epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    planId,
    dayIndex,
    completedOnEpochDay,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('completed_on_epoch_day')) {
      context.handle(
        _completedOnEpochDayMeta,
        completedOnEpochDay.isAcceptableOrUnknown(
          data['completed_on_epoch_day']!,
          _completedOnEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedOnEpochDayMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {planId, dayIndex};
  @override
  DayCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCompletion(
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      completedOnEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_on_epoch_day'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $DayCompletionsTable createAlias(String alias) {
    return $DayCompletionsTable(attachedDatabase, alias);
  }
}

class DayCompletion extends DataClass implements Insertable<DayCompletion> {
  final int planId;
  final int dayIndex;
  final int completedOnEpochDay;
  final DateTime completedAt;
  const DayCompletion({
    required this.planId,
    required this.dayIndex,
    required this.completedOnEpochDay,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plan_id'] = Variable<int>(planId);
    map['day_index'] = Variable<int>(dayIndex);
    map['completed_on_epoch_day'] = Variable<int>(completedOnEpochDay);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  DayCompletionsCompanion toCompanion(bool nullToAbsent) {
    return DayCompletionsCompanion(
      planId: Value(planId),
      dayIndex: Value(dayIndex),
      completedOnEpochDay: Value(completedOnEpochDay),
      completedAt: Value(completedAt),
    );
  }

  factory DayCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCompletion(
      planId: serializer.fromJson<int>(json['planId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      completedOnEpochDay: serializer.fromJson<int>(
        json['completedOnEpochDay'],
      ),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'planId': serializer.toJson<int>(planId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'completedOnEpochDay': serializer.toJson<int>(completedOnEpochDay),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  DayCompletion copyWith({
    int? planId,
    int? dayIndex,
    int? completedOnEpochDay,
    DateTime? completedAt,
  }) => DayCompletion(
    planId: planId ?? this.planId,
    dayIndex: dayIndex ?? this.dayIndex,
    completedOnEpochDay: completedOnEpochDay ?? this.completedOnEpochDay,
    completedAt: completedAt ?? this.completedAt,
  );
  DayCompletion copyWithCompanion(DayCompletionsCompanion data) {
    return DayCompletion(
      planId: data.planId.present ? data.planId.value : this.planId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      completedOnEpochDay: data.completedOnEpochDay.present
          ? data.completedOnEpochDay.value
          : this.completedOnEpochDay,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayCompletion(')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('completedOnEpochDay: $completedOnEpochDay, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(planId, dayIndex, completedOnEpochDay, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayCompletion &&
          other.planId == this.planId &&
          other.dayIndex == this.dayIndex &&
          other.completedOnEpochDay == this.completedOnEpochDay &&
          other.completedAt == this.completedAt);
}

class DayCompletionsCompanion extends UpdateCompanion<DayCompletion> {
  final Value<int> planId;
  final Value<int> dayIndex;
  final Value<int> completedOnEpochDay;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const DayCompletionsCompanion({
    this.planId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.completedOnEpochDay = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayCompletionsCompanion.insert({
    required int planId,
    required int dayIndex,
    required int completedOnEpochDay,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : planId = Value(planId),
       dayIndex = Value(dayIndex),
       completedOnEpochDay = Value(completedOnEpochDay),
       completedAt = Value(completedAt);
  static Insertable<DayCompletion> custom({
    Expression<int>? planId,
    Expression<int>? dayIndex,
    Expression<int>? completedOnEpochDay,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (planId != null) 'plan_id': planId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (completedOnEpochDay != null)
        'completed_on_epoch_day': completedOnEpochDay,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayCompletionsCompanion copyWith({
    Value<int>? planId,
    Value<int>? dayIndex,
    Value<int>? completedOnEpochDay,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return DayCompletionsCompanion(
      planId: planId ?? this.planId,
      dayIndex: dayIndex ?? this.dayIndex,
      completedOnEpochDay: completedOnEpochDay ?? this.completedOnEpochDay,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (completedOnEpochDay.present) {
      map['completed_on_epoch_day'] = Variable<int>(completedOnEpochDay.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayCompletionsCompanion(')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('completedOnEpochDay: $completedOnEpochDay, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterCompletionsTable extends ChapterCompletions
    with TableInfo<$ChapterCompletionsTable, ChapterCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, chapter, completedAt, planId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, chapter};
  @override
  ChapterCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterCompletion(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
    );
  }

  @override
  $ChapterCompletionsTable createAlias(String alias) {
    return $ChapterCompletionsTable(attachedDatabase, alias);
  }
}

class ChapterCompletion extends DataClass
    implements Insertable<ChapterCompletion> {
  final String bookId;
  final int chapter;
  final DateTime completedAt;
  final int? planId;
  const ChapterCompletion({
    required this.bookId,
    required this.chapter,
    required this.completedAt,
    this.planId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['chapter'] = Variable<int>(chapter);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    return map;
  }

  ChapterCompletionsCompanion toCompanion(bool nullToAbsent) {
    return ChapterCompletionsCompanion(
      bookId: Value(bookId),
      chapter: Value(chapter),
      completedAt: Value(completedAt),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
    );
  }

  factory ChapterCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterCompletion(
      bookId: serializer.fromJson<String>(json['bookId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      planId: serializer.fromJson<int?>(json['planId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'chapter': serializer.toJson<int>(chapter),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'planId': serializer.toJson<int?>(planId),
    };
  }

  ChapterCompletion copyWith({
    String? bookId,
    int? chapter,
    DateTime? completedAt,
    Value<int?> planId = const Value.absent(),
  }) => ChapterCompletion(
    bookId: bookId ?? this.bookId,
    chapter: chapter ?? this.chapter,
    completedAt: completedAt ?? this.completedAt,
    planId: planId.present ? planId.value : this.planId,
  );
  ChapterCompletion copyWithCompanion(ChapterCompletionsCompanion data) {
    return ChapterCompletion(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      planId: data.planId.present ? data.planId.value : this.planId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterCompletion(')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('completedAt: $completedAt, ')
          ..write('planId: $planId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, chapter, completedAt, planId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterCompletion &&
          other.bookId == this.bookId &&
          other.chapter == this.chapter &&
          other.completedAt == this.completedAt &&
          other.planId == this.planId);
}

class ChapterCompletionsCompanion extends UpdateCompanion<ChapterCompletion> {
  final Value<String> bookId;
  final Value<int> chapter;
  final Value<DateTime> completedAt;
  final Value<int?> planId;
  final Value<int> rowid;
  const ChapterCompletionsCompanion({
    this.bookId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.planId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterCompletionsCompanion.insert({
    required String bookId,
    required int chapter,
    required DateTime completedAt,
    this.planId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       chapter = Value(chapter),
       completedAt = Value(completedAt);
  static Insertable<ChapterCompletion> custom({
    Expression<String>? bookId,
    Expression<int>? chapter,
    Expression<DateTime>? completedAt,
    Expression<int>? planId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (completedAt != null) 'completed_at': completedAt,
      if (planId != null) 'plan_id': planId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterCompletionsCompanion copyWith({
    Value<String>? bookId,
    Value<int>? chapter,
    Value<DateTime>? completedAt,
    Value<int?>? planId,
    Value<int>? rowid,
  }) {
    return ChapterCompletionsCompanion(
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      completedAt: completedAt ?? this.completedAt,
      planId: planId ?? this.planId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterCompletionsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('completedAt: $completedAt, ')
          ..write('planId: $planId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredMsMeta = const VerificationMeta(
    'requiredMs',
  );
  @override
  late final GeneratedColumn<int> requiredMs = GeneratedColumn<int>(
    'required_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foregroundMsMeta = const VerificationMeta(
    'foregroundMs',
  );
  @override
  late final GeneratedColumn<int> foregroundMs = GeneratedColumn<int>(
    'foreground_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invalidatedReasonMeta = const VerificationMeta(
    'invalidatedReason',
  );
  @override
  late final GeneratedColumn<String> invalidatedReason =
      GeneratedColumn<String>(
        'invalidated_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _passageTitleMeta = const VerificationMeta(
    'passageTitle',
  );
  @override
  late final GeneratedColumn<String> passageTitle = GeneratedColumn<String>(
    'passage_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passageBookIdMeta = const VerificationMeta(
    'passageBookId',
  );
  @override
  late final GeneratedColumn<String> passageBookId = GeneratedColumn<String>(
    'passage_book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passageFromMeta = const VerificationMeta(
    'passageFrom',
  );
  @override
  late final GeneratedColumn<int> passageFrom = GeneratedColumn<int>(
    'passage_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passageToMeta = const VerificationMeta(
    'passageTo',
  );
  @override
  late final GeneratedColumn<int> passageTo = GeneratedColumn<int>(
    'passage_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    dayIndex,
    startedAt,
    requiredMs,
    foregroundMs,
    completedAt,
    invalidatedReason,
    passageTitle,
    passageBookId,
    passageFrom,
    passageTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('required_ms')) {
      context.handle(
        _requiredMsMeta,
        requiredMs.isAcceptableOrUnknown(data['required_ms']!, _requiredMsMeta),
      );
    } else if (isInserting) {
      context.missing(_requiredMsMeta);
    }
    if (data.containsKey('foreground_ms')) {
      context.handle(
        _foregroundMsMeta,
        foregroundMs.isAcceptableOrUnknown(
          data['foreground_ms']!,
          _foregroundMsMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('invalidated_reason')) {
      context.handle(
        _invalidatedReasonMeta,
        invalidatedReason.isAcceptableOrUnknown(
          data['invalidated_reason']!,
          _invalidatedReasonMeta,
        ),
      );
    }
    if (data.containsKey('passage_title')) {
      context.handle(
        _passageTitleMeta,
        passageTitle.isAcceptableOrUnknown(
          data['passage_title']!,
          _passageTitleMeta,
        ),
      );
    }
    if (data.containsKey('passage_book_id')) {
      context.handle(
        _passageBookIdMeta,
        passageBookId.isAcceptableOrUnknown(
          data['passage_book_id']!,
          _passageBookIdMeta,
        ),
      );
    }
    if (data.containsKey('passage_from')) {
      context.handle(
        _passageFromMeta,
        passageFrom.isAcceptableOrUnknown(
          data['passage_from']!,
          _passageFromMeta,
        ),
      );
    }
    if (data.containsKey('passage_to')) {
      context.handle(
        _passageToMeta,
        passageTo.isAcceptableOrUnknown(data['passage_to']!, _passageToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      requiredMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}required_ms'],
      )!,
      foregroundMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foreground_ms'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      invalidatedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invalidated_reason'],
      ),
      passageTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passage_title'],
      ),
      passageBookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passage_book_id'],
      ),
      passageFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passage_from'],
      ),
      passageTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passage_to'],
      ),
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final int id;
  final int planId;
  final int dayIndex;
  final DateTime startedAt;
  final int requiredMs;
  final int foregroundMs;
  final DateTime? completedAt;
  final String? invalidatedReason;

  /// A one-time reading outside the plan ("Sermon on the Mount", Matthew
  /// 5–7). When set, `dayIndex` is -1 and the session is not a plan day: its
  /// chapters still land in `chapter_completions`, it does not complete a
  /// `day_completions` row and does not move the streak.
  final String? passageTitle;
  final String? passageBookId;
  final int? passageFrom;
  final int? passageTo;
  const ReadingSession({
    required this.id,
    required this.planId,
    required this.dayIndex,
    required this.startedAt,
    required this.requiredMs,
    required this.foregroundMs,
    this.completedAt,
    this.invalidatedReason,
    this.passageTitle,
    this.passageBookId,
    this.passageFrom,
    this.passageTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['day_index'] = Variable<int>(dayIndex);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['required_ms'] = Variable<int>(requiredMs);
    map['foreground_ms'] = Variable<int>(foregroundMs);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || invalidatedReason != null) {
      map['invalidated_reason'] = Variable<String>(invalidatedReason);
    }
    if (!nullToAbsent || passageTitle != null) {
      map['passage_title'] = Variable<String>(passageTitle);
    }
    if (!nullToAbsent || passageBookId != null) {
      map['passage_book_id'] = Variable<String>(passageBookId);
    }
    if (!nullToAbsent || passageFrom != null) {
      map['passage_from'] = Variable<int>(passageFrom);
    }
    if (!nullToAbsent || passageTo != null) {
      map['passage_to'] = Variable<int>(passageTo);
    }
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      planId: Value(planId),
      dayIndex: Value(dayIndex),
      startedAt: Value(startedAt),
      requiredMs: Value(requiredMs),
      foregroundMs: Value(foregroundMs),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      invalidatedReason: invalidatedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(invalidatedReason),
      passageTitle: passageTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(passageTitle),
      passageBookId: passageBookId == null && nullToAbsent
          ? const Value.absent()
          : Value(passageBookId),
      passageFrom: passageFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(passageFrom),
      passageTo: passageTo == null && nullToAbsent
          ? const Value.absent()
          : Value(passageTo),
    );
  }

  factory ReadingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      requiredMs: serializer.fromJson<int>(json['requiredMs']),
      foregroundMs: serializer.fromJson<int>(json['foregroundMs']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      invalidatedReason: serializer.fromJson<String?>(
        json['invalidatedReason'],
      ),
      passageTitle: serializer.fromJson<String?>(json['passageTitle']),
      passageBookId: serializer.fromJson<String?>(json['passageBookId']),
      passageFrom: serializer.fromJson<int?>(json['passageFrom']),
      passageTo: serializer.fromJson<int?>(json['passageTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'requiredMs': serializer.toJson<int>(requiredMs),
      'foregroundMs': serializer.toJson<int>(foregroundMs),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'invalidatedReason': serializer.toJson<String?>(invalidatedReason),
      'passageTitle': serializer.toJson<String?>(passageTitle),
      'passageBookId': serializer.toJson<String?>(passageBookId),
      'passageFrom': serializer.toJson<int?>(passageFrom),
      'passageTo': serializer.toJson<int?>(passageTo),
    };
  }

  ReadingSession copyWith({
    int? id,
    int? planId,
    int? dayIndex,
    DateTime? startedAt,
    int? requiredMs,
    int? foregroundMs,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> invalidatedReason = const Value.absent(),
    Value<String?> passageTitle = const Value.absent(),
    Value<String?> passageBookId = const Value.absent(),
    Value<int?> passageFrom = const Value.absent(),
    Value<int?> passageTo = const Value.absent(),
  }) => ReadingSession(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    dayIndex: dayIndex ?? this.dayIndex,
    startedAt: startedAt ?? this.startedAt,
    requiredMs: requiredMs ?? this.requiredMs,
    foregroundMs: foregroundMs ?? this.foregroundMs,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    invalidatedReason: invalidatedReason.present
        ? invalidatedReason.value
        : this.invalidatedReason,
    passageTitle: passageTitle.present ? passageTitle.value : this.passageTitle,
    passageBookId: passageBookId.present
        ? passageBookId.value
        : this.passageBookId,
    passageFrom: passageFrom.present ? passageFrom.value : this.passageFrom,
    passageTo: passageTo.present ? passageTo.value : this.passageTo,
  );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      requiredMs: data.requiredMs.present
          ? data.requiredMs.value
          : this.requiredMs,
      foregroundMs: data.foregroundMs.present
          ? data.foregroundMs.value
          : this.foregroundMs,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      invalidatedReason: data.invalidatedReason.present
          ? data.invalidatedReason.value
          : this.invalidatedReason,
      passageTitle: data.passageTitle.present
          ? data.passageTitle.value
          : this.passageTitle,
      passageBookId: data.passageBookId.present
          ? data.passageBookId.value
          : this.passageBookId,
      passageFrom: data.passageFrom.present
          ? data.passageFrom.value
          : this.passageFrom,
      passageTo: data.passageTo.present ? data.passageTo.value : this.passageTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('startedAt: $startedAt, ')
          ..write('requiredMs: $requiredMs, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('invalidatedReason: $invalidatedReason, ')
          ..write('passageTitle: $passageTitle, ')
          ..write('passageBookId: $passageBookId, ')
          ..write('passageFrom: $passageFrom, ')
          ..write('passageTo: $passageTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    dayIndex,
    startedAt,
    requiredMs,
    foregroundMs,
    completedAt,
    invalidatedReason,
    passageTitle,
    passageBookId,
    passageFrom,
    passageTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.dayIndex == this.dayIndex &&
          other.startedAt == this.startedAt &&
          other.requiredMs == this.requiredMs &&
          other.foregroundMs == this.foregroundMs &&
          other.completedAt == this.completedAt &&
          other.invalidatedReason == this.invalidatedReason &&
          other.passageTitle == this.passageTitle &&
          other.passageBookId == this.passageBookId &&
          other.passageFrom == this.passageFrom &&
          other.passageTo == this.passageTo);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> dayIndex;
  final Value<DateTime> startedAt;
  final Value<int> requiredMs;
  final Value<int> foregroundMs;
  final Value<DateTime?> completedAt;
  final Value<String?> invalidatedReason;
  final Value<String?> passageTitle;
  final Value<String?> passageBookId;
  final Value<int?> passageFrom;
  final Value<int?> passageTo;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.requiredMs = const Value.absent(),
    this.foregroundMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.invalidatedReason = const Value.absent(),
    this.passageTitle = const Value.absent(),
    this.passageBookId = const Value.absent(),
    this.passageFrom = const Value.absent(),
    this.passageTo = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required int dayIndex,
    required DateTime startedAt,
    required int requiredMs,
    this.foregroundMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.invalidatedReason = const Value.absent(),
    this.passageTitle = const Value.absent(),
    this.passageBookId = const Value.absent(),
    this.passageFrom = const Value.absent(),
    this.passageTo = const Value.absent(),
  }) : planId = Value(planId),
       dayIndex = Value(dayIndex),
       startedAt = Value(startedAt),
       requiredMs = Value(requiredMs);
  static Insertable<ReadingSession> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? dayIndex,
    Expression<DateTime>? startedAt,
    Expression<int>? requiredMs,
    Expression<int>? foregroundMs,
    Expression<DateTime>? completedAt,
    Expression<String>? invalidatedReason,
    Expression<String>? passageTitle,
    Expression<String>? passageBookId,
    Expression<int>? passageFrom,
    Expression<int>? passageTo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (startedAt != null) 'started_at': startedAt,
      if (requiredMs != null) 'required_ms': requiredMs,
      if (foregroundMs != null) 'foreground_ms': foregroundMs,
      if (completedAt != null) 'completed_at': completedAt,
      if (invalidatedReason != null) 'invalidated_reason': invalidatedReason,
      if (passageTitle != null) 'passage_title': passageTitle,
      if (passageBookId != null) 'passage_book_id': passageBookId,
      if (passageFrom != null) 'passage_from': passageFrom,
      if (passageTo != null) 'passage_to': passageTo,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<int>? dayIndex,
    Value<DateTime>? startedAt,
    Value<int>? requiredMs,
    Value<int>? foregroundMs,
    Value<DateTime?>? completedAt,
    Value<String?>? invalidatedReason,
    Value<String?>? passageTitle,
    Value<String?>? passageBookId,
    Value<int?>? passageFrom,
    Value<int?>? passageTo,
  }) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayIndex: dayIndex ?? this.dayIndex,
      startedAt: startedAt ?? this.startedAt,
      requiredMs: requiredMs ?? this.requiredMs,
      foregroundMs: foregroundMs ?? this.foregroundMs,
      completedAt: completedAt ?? this.completedAt,
      invalidatedReason: invalidatedReason ?? this.invalidatedReason,
      passageTitle: passageTitle ?? this.passageTitle,
      passageBookId: passageBookId ?? this.passageBookId,
      passageFrom: passageFrom ?? this.passageFrom,
      passageTo: passageTo ?? this.passageTo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (requiredMs.present) {
      map['required_ms'] = Variable<int>(requiredMs.value);
    }
    if (foregroundMs.present) {
      map['foreground_ms'] = Variable<int>(foregroundMs.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (invalidatedReason.present) {
      map['invalidated_reason'] = Variable<String>(invalidatedReason.value);
    }
    if (passageTitle.present) {
      map['passage_title'] = Variable<String>(passageTitle.value);
    }
    if (passageBookId.present) {
      map['passage_book_id'] = Variable<String>(passageBookId.value);
    }
    if (passageFrom.present) {
      map['passage_from'] = Variable<int>(passageFrom.value);
    }
    if (passageTo.present) {
      map['passage_to'] = Variable<int>(passageTo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('startedAt: $startedAt, ')
          ..write('requiredMs: $requiredMs, ')
          ..write('foregroundMs: $foregroundMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('invalidatedReason: $invalidatedReason, ')
          ..write('passageTitle: $passageTitle, ')
          ..write('passageBookId: $passageBookId, ')
          ..write('passageFrom: $passageFrom, ')
          ..write('passageTo: $passageTo')
          ..write(')'))
        .toString();
  }
}

class $StreaksTable extends Streaks with TableInfo<$StreaksTable, Streak> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreaksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentMeta = const VerificationMeta(
    'current',
  );
  @override
  late final GeneratedColumn<int> current = GeneratedColumn<int>(
    'current',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestMeta = const VerificationMeta(
    'longest',
  );
  @override
  late final GeneratedColumn<int> longest = GeneratedColumn<int>(
    'longest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCompletedOnEpochDayMeta =
      const VerificationMeta('lastCompletedOnEpochDay');
  @override
  late final GeneratedColumn<int> lastCompletedOnEpochDay =
      GeneratedColumn<int>(
        'last_completed_on_epoch_day',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    current,
    longest,
    lastCompletedOnEpochDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streaks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Streak> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current')) {
      context.handle(
        _currentMeta,
        current.isAcceptableOrUnknown(data['current']!, _currentMeta),
      );
    }
    if (data.containsKey('longest')) {
      context.handle(
        _longestMeta,
        longest.isAcceptableOrUnknown(data['longest']!, _longestMeta),
      );
    }
    if (data.containsKey('last_completed_on_epoch_day')) {
      context.handle(
        _lastCompletedOnEpochDayMeta,
        lastCompletedOnEpochDay.isAcceptableOrUnknown(
          data['last_completed_on_epoch_day']!,
          _lastCompletedOnEpochDayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Streak map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Streak(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      current: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current'],
      )!,
      longest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest'],
      )!,
      lastCompletedOnEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_completed_on_epoch_day'],
      ),
    );
  }

  @override
  $StreaksTable createAlias(String alias) {
    return $StreaksTable(attachedDatabase, alias);
  }
}

class Streak extends DataClass implements Insertable<Streak> {
  final int id;
  final int current;
  final int longest;
  final int? lastCompletedOnEpochDay;
  const Streak({
    required this.id,
    required this.current,
    required this.longest,
    this.lastCompletedOnEpochDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current'] = Variable<int>(current);
    map['longest'] = Variable<int>(longest);
    if (!nullToAbsent || lastCompletedOnEpochDay != null) {
      map['last_completed_on_epoch_day'] = Variable<int>(
        lastCompletedOnEpochDay,
      );
    }
    return map;
  }

  StreaksCompanion toCompanion(bool nullToAbsent) {
    return StreaksCompanion(
      id: Value(id),
      current: Value(current),
      longest: Value(longest),
      lastCompletedOnEpochDay: lastCompletedOnEpochDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedOnEpochDay),
    );
  }

  factory Streak.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Streak(
      id: serializer.fromJson<int>(json['id']),
      current: serializer.fromJson<int>(json['current']),
      longest: serializer.fromJson<int>(json['longest']),
      lastCompletedOnEpochDay: serializer.fromJson<int?>(
        json['lastCompletedOnEpochDay'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'current': serializer.toJson<int>(current),
      'longest': serializer.toJson<int>(longest),
      'lastCompletedOnEpochDay': serializer.toJson<int?>(
        lastCompletedOnEpochDay,
      ),
    };
  }

  Streak copyWith({
    int? id,
    int? current,
    int? longest,
    Value<int?> lastCompletedOnEpochDay = const Value.absent(),
  }) => Streak(
    id: id ?? this.id,
    current: current ?? this.current,
    longest: longest ?? this.longest,
    lastCompletedOnEpochDay: lastCompletedOnEpochDay.present
        ? lastCompletedOnEpochDay.value
        : this.lastCompletedOnEpochDay,
  );
  Streak copyWithCompanion(StreaksCompanion data) {
    return Streak(
      id: data.id.present ? data.id.value : this.id,
      current: data.current.present ? data.current.value : this.current,
      longest: data.longest.present ? data.longest.value : this.longest,
      lastCompletedOnEpochDay: data.lastCompletedOnEpochDay.present
          ? data.lastCompletedOnEpochDay.value
          : this.lastCompletedOnEpochDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Streak(')
          ..write('id: $id, ')
          ..write('current: $current, ')
          ..write('longest: $longest, ')
          ..write('lastCompletedOnEpochDay: $lastCompletedOnEpochDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, current, longest, lastCompletedOnEpochDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Streak &&
          other.id == this.id &&
          other.current == this.current &&
          other.longest == this.longest &&
          other.lastCompletedOnEpochDay == this.lastCompletedOnEpochDay);
}

class StreaksCompanion extends UpdateCompanion<Streak> {
  final Value<int> id;
  final Value<int> current;
  final Value<int> longest;
  final Value<int?> lastCompletedOnEpochDay;
  const StreaksCompanion({
    this.id = const Value.absent(),
    this.current = const Value.absent(),
    this.longest = const Value.absent(),
    this.lastCompletedOnEpochDay = const Value.absent(),
  });
  StreaksCompanion.insert({
    this.id = const Value.absent(),
    this.current = const Value.absent(),
    this.longest = const Value.absent(),
    this.lastCompletedOnEpochDay = const Value.absent(),
  });
  static Insertable<Streak> custom({
    Expression<int>? id,
    Expression<int>? current,
    Expression<int>? longest,
    Expression<int>? lastCompletedOnEpochDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (current != null) 'current': current,
      if (longest != null) 'longest': longest,
      if (lastCompletedOnEpochDay != null)
        'last_completed_on_epoch_day': lastCompletedOnEpochDay,
    });
  }

  StreaksCompanion copyWith({
    Value<int>? id,
    Value<int>? current,
    Value<int>? longest,
    Value<int?>? lastCompletedOnEpochDay,
  }) {
    return StreaksCompanion(
      id: id ?? this.id,
      current: current ?? this.current,
      longest: longest ?? this.longest,
      lastCompletedOnEpochDay:
          lastCompletedOnEpochDay ?? this.lastCompletedOnEpochDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (current.present) {
      map['current'] = Variable<int>(current.value);
    }
    if (longest.present) {
      map['longest'] = Variable<int>(longest.value);
    }
    if (lastCompletedOnEpochDay.present) {
      map['last_completed_on_epoch_day'] = Variable<int>(
        lastCompletedOnEpochDay.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreaksCompanion(')
          ..write('id: $id, ')
          ..write('current: $current, ')
          ..write('longest: $longest, ')
          ..write('lastCompletedOnEpochDay: $lastCompletedOnEpochDay')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _badgeIdMeta = const VerificationMeta(
    'badgeId',
  );
  @override
  late final GeneratedColumn<String> badgeId = GeneratedColumn<String>(
    'badge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [badgeId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('badge_id')) {
      context.handle(
        _badgeIdMeta,
        badgeId.isAcceptableOrUnknown(data['badge_id']!, _badgeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {badgeId};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      badgeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String badgeId;
  final DateTime unlockedAt;
  const Achievement({required this.badgeId, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['badge_id'] = Variable<String>(badgeId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      badgeId: Value(badgeId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      badgeId: serializer.fromJson<String>(json['badgeId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'badgeId': serializer.toJson<String>(badgeId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  Achievement copyWith({String? badgeId, DateTime? unlockedAt}) => Achievement(
    badgeId: badgeId ?? this.badgeId,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('badgeId: $badgeId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(badgeId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.badgeId == this.badgeId &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> badgeId;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.badgeId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String badgeId,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : badgeId = Value(badgeId),
       unlockedAt = Value(unlockedAt);
  static Insertable<Achievement> custom({
    Expression<String>? badgeId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (badgeId != null) 'badge_id': badgeId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? badgeId,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      badgeId: badgeId ?? this.badgeId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('badgeId: $badgeId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReadingPlansTable readingPlans = $ReadingPlansTable(this);
  late final $DayCompletionsTable dayCompletions = $DayCompletionsTable(this);
  late final $ChapterCompletionsTable chapterCompletions =
      $ChapterCompletionsTable(this);
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $StreaksTable streaks = $StreaksTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    readingPlans,
    dayCompletions,
    chapterCompletions,
    readingSessions,
    streaks,
    achievements,
  ];
}

typedef $$ReadingPlansTableCreateCompanionBuilder =
    ReadingPlansCompanion Function({
      Value<int> id,
      required String scopeCode,
      required int targetDays,
      required int startEpochDay,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$ReadingPlansTableUpdateCompanionBuilder =
    ReadingPlansCompanion Function({
      Value<int> id,
      Value<String> scopeCode,
      Value<int> targetDays,
      Value<int> startEpochDay,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$ReadingPlansTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingPlansTable> {
  $$ReadingPlansTableFilterComposer({
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

  ColumnFilters<String> get scopeCode => $composableBuilder(
    column: $table.scopeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingPlansTable> {
  $$ReadingPlansTableOrderingComposer({
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

  ColumnOrderings<String> get scopeCode => $composableBuilder(
    column: $table.scopeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingPlansTable> {
  $$ReadingPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scopeCode =>
      $composableBuilder(column: $table.scopeCode, builder: (column) => column);

  GeneratedColumn<int> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startEpochDay => $composableBuilder(
    column: $table.startEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReadingPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingPlansTable,
          ReadingPlan,
          $$ReadingPlansTableFilterComposer,
          $$ReadingPlansTableOrderingComposer,
          $$ReadingPlansTableAnnotationComposer,
          $$ReadingPlansTableCreateCompanionBuilder,
          $$ReadingPlansTableUpdateCompanionBuilder,
          (
            ReadingPlan,
            BaseReferences<_$AppDatabase, $ReadingPlansTable, ReadingPlan>,
          ),
          ReadingPlan,
          PrefetchHooks Function()
        > {
  $$ReadingPlansTableTableManager(_$AppDatabase db, $ReadingPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scopeCode = const Value.absent(),
                Value<int> targetDays = const Value.absent(),
                Value<int> startEpochDay = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReadingPlansCompanion(
                id: id,
                scopeCode: scopeCode,
                targetDays: targetDays,
                startEpochDay: startEpochDay,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scopeCode,
                required int targetDays,
                required int startEpochDay,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => ReadingPlansCompanion.insert(
                id: id,
                scopeCode: scopeCode,
                targetDays: targetDays,
                startEpochDay: startEpochDay,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingPlansTable, ReadingPlan>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReadingPlansTable,
                    ReadingPlan
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingPlansTable,
      ReadingPlan,
      $$ReadingPlansTableFilterComposer,
      $$ReadingPlansTableOrderingComposer,
      $$ReadingPlansTableAnnotationComposer,
      $$ReadingPlansTableCreateCompanionBuilder,
      $$ReadingPlansTableUpdateCompanionBuilder,
      (
        ReadingPlan,
        BaseReferences<_$AppDatabase, $ReadingPlansTable, ReadingPlan>,
      ),
      ReadingPlan,
      PrefetchHooks Function()
    >;
typedef $$DayCompletionsTableCreateCompanionBuilder =
    DayCompletionsCompanion Function({
      required int planId,
      required int dayIndex,
      required int completedOnEpochDay,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$DayCompletionsTableUpdateCompanionBuilder =
    DayCompletionsCompanion Function({
      Value<int> planId,
      Value<int> dayIndex,
      Value<int> completedOnEpochDay,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$DayCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $DayCompletionsTable> {
  $$DayCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedOnEpochDay => $composableBuilder(
    column: $table.completedOnEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DayCompletionsTable> {
  $$DayCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedOnEpochDay => $composableBuilder(
    column: $table.completedOnEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayCompletionsTable> {
  $$DayCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<int> get completedOnEpochDay => $composableBuilder(
    column: $table.completedOnEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$DayCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayCompletionsTable,
          DayCompletion,
          $$DayCompletionsTableFilterComposer,
          $$DayCompletionsTableOrderingComposer,
          $$DayCompletionsTableAnnotationComposer,
          $$DayCompletionsTableCreateCompanionBuilder,
          $$DayCompletionsTableUpdateCompanionBuilder,
          (
            DayCompletion,
            BaseReferences<_$AppDatabase, $DayCompletionsTable, DayCompletion>,
          ),
          DayCompletion,
          PrefetchHooks Function()
        > {
  $$DayCompletionsTableTableManager(
    _$AppDatabase db,
    $DayCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> planId = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<int> completedOnEpochDay = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayCompletionsCompanion(
                planId: planId,
                dayIndex: dayIndex,
                completedOnEpochDay: completedOnEpochDay,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int planId,
                required int dayIndex,
                required int completedOnEpochDay,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => DayCompletionsCompanion.insert(
                planId: planId,
                dayIndex: dayIndex,
                completedOnEpochDay: completedOnEpochDay,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayCompletionsTable, DayCompletion>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DayCompletionsTable,
                    DayCompletion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayCompletionsTable,
      DayCompletion,
      $$DayCompletionsTableFilterComposer,
      $$DayCompletionsTableOrderingComposer,
      $$DayCompletionsTableAnnotationComposer,
      $$DayCompletionsTableCreateCompanionBuilder,
      $$DayCompletionsTableUpdateCompanionBuilder,
      (
        DayCompletion,
        BaseReferences<_$AppDatabase, $DayCompletionsTable, DayCompletion>,
      ),
      DayCompletion,
      PrefetchHooks Function()
    >;
typedef $$ChapterCompletionsTableCreateCompanionBuilder =
    ChapterCompletionsCompanion Function({
      required String bookId,
      required int chapter,
      required DateTime completedAt,
      Value<int?> planId,
      Value<int> rowid,
    });
typedef $$ChapterCompletionsTableUpdateCompanionBuilder =
    ChapterCompletionsCompanion Function({
      Value<String> bookId,
      Value<int> chapter,
      Value<DateTime> completedAt,
      Value<int?> planId,
      Value<int> rowid,
    });

class $$ChapterCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterCompletionsTable> {
  $$ChapterCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterCompletionsTable> {
  $$ChapterCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterCompletionsTable> {
  $$ChapterCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);
}

class $$ChapterCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterCompletionsTable,
          ChapterCompletion,
          $$ChapterCompletionsTableFilterComposer,
          $$ChapterCompletionsTableOrderingComposer,
          $$ChapterCompletionsTableAnnotationComposer,
          $$ChapterCompletionsTableCreateCompanionBuilder,
          $$ChapterCompletionsTableUpdateCompanionBuilder,
          (
            ChapterCompletion,
            BaseReferences<
              _$AppDatabase,
              $ChapterCompletionsTable,
              ChapterCompletion
            >,
          ),
          ChapterCompletion,
          PrefetchHooks Function()
        > {
  $$ChapterCompletionsTableTableManager(
    _$AppDatabase db,
    $ChapterCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterCompletionsCompanion(
                bookId: bookId,
                chapter: chapter,
                completedAt: completedAt,
                planId: planId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required int chapter,
                required DateTime completedAt,
                Value<int?> planId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterCompletionsCompanion.insert(
                bookId: bookId,
                chapter: chapter,
                completedAt: completedAt,
                planId: planId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChapterCompletionsTable, ChapterCompletion>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ChapterCompletionsTable,
                    ChapterCompletion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterCompletionsTable,
      ChapterCompletion,
      $$ChapterCompletionsTableFilterComposer,
      $$ChapterCompletionsTableOrderingComposer,
      $$ChapterCompletionsTableAnnotationComposer,
      $$ChapterCompletionsTableCreateCompanionBuilder,
      $$ChapterCompletionsTableUpdateCompanionBuilder,
      (
        ChapterCompletion,
        BaseReferences<
          _$AppDatabase,
          $ChapterCompletionsTable,
          ChapterCompletion
        >,
      ),
      ChapterCompletion,
      PrefetchHooks Function()
    >;
typedef $$ReadingSessionsTableCreateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      required int planId,
      required int dayIndex,
      required DateTime startedAt,
      required int requiredMs,
      Value<int> foregroundMs,
      Value<DateTime?> completedAt,
      Value<String?> invalidatedReason,
      Value<String?> passageTitle,
      Value<String?> passageBookId,
      Value<int?> passageFrom,
      Value<int?> passageTo,
    });
typedef $$ReadingSessionsTableUpdateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<int> dayIndex,
      Value<DateTime> startedAt,
      Value<int> requiredMs,
      Value<int> foregroundMs,
      Value<DateTime?> completedAt,
      Value<String?> invalidatedReason,
      Value<String?> passageTitle,
      Value<String?> passageBookId,
      Value<int?> passageFrom,
      Value<int?> passageTo,
    });

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
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

  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requiredMs => $composableBuilder(
    column: $table.requiredMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invalidatedReason => $composableBuilder(
    column: $table.invalidatedReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passageTitle => $composableBuilder(
    column: $table.passageTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passageBookId => $composableBuilder(
    column: $table.passageBookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passageFrom => $composableBuilder(
    column: $table.passageFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passageTo => $composableBuilder(
    column: $table.passageTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requiredMs => $composableBuilder(
    column: $table.requiredMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invalidatedReason => $composableBuilder(
    column: $table.invalidatedReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passageTitle => $composableBuilder(
    column: $table.passageTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passageBookId => $composableBuilder(
    column: $table.passageBookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passageFrom => $composableBuilder(
    column: $table.passageFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passageTo => $composableBuilder(
    column: $table.passageTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get requiredMs => $composableBuilder(
    column: $table.requiredMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get foregroundMs => $composableBuilder(
    column: $table.foregroundMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invalidatedReason => $composableBuilder(
    column: $table.invalidatedReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passageTitle => $composableBuilder(
    column: $table.passageTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passageBookId => $composableBuilder(
    column: $table.passageBookId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passageFrom => $composableBuilder(
    column: $table.passageFrom,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passageTo =>
      $composableBuilder(column: $table.passageTo, builder: (column) => column);
}

class $$ReadingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingSessionsTable,
          ReadingSession,
          $$ReadingSessionsTableFilterComposer,
          $$ReadingSessionsTableOrderingComposer,
          $$ReadingSessionsTableAnnotationComposer,
          $$ReadingSessionsTableCreateCompanionBuilder,
          $$ReadingSessionsTableUpdateCompanionBuilder,
          (
            ReadingSession,
            BaseReferences<
              _$AppDatabase,
              $ReadingSessionsTable,
              ReadingSession
            >,
          ),
          ReadingSession,
          PrefetchHooks Function()
        > {
  $$ReadingSessionsTableTableManager(
    _$AppDatabase db,
    $ReadingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> requiredMs = const Value.absent(),
                Value<int> foregroundMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> invalidatedReason = const Value.absent(),
                Value<String?> passageTitle = const Value.absent(),
                Value<String?> passageBookId = const Value.absent(),
                Value<int?> passageFrom = const Value.absent(),
                Value<int?> passageTo = const Value.absent(),
              }) => ReadingSessionsCompanion(
                id: id,
                planId: planId,
                dayIndex: dayIndex,
                startedAt: startedAt,
                requiredMs: requiredMs,
                foregroundMs: foregroundMs,
                completedAt: completedAt,
                invalidatedReason: invalidatedReason,
                passageTitle: passageTitle,
                passageBookId: passageBookId,
                passageFrom: passageFrom,
                passageTo: passageTo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                required int dayIndex,
                required DateTime startedAt,
                required int requiredMs,
                Value<int> foregroundMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> invalidatedReason = const Value.absent(),
                Value<String?> passageTitle = const Value.absent(),
                Value<String?> passageBookId = const Value.absent(),
                Value<int?> passageFrom = const Value.absent(),
                Value<int?> passageTo = const Value.absent(),
              }) => ReadingSessionsCompanion.insert(
                id: id,
                planId: planId,
                dayIndex: dayIndex,
                startedAt: startedAt,
                requiredMs: requiredMs,
                foregroundMs: foregroundMs,
                completedAt: completedAt,
                invalidatedReason: invalidatedReason,
                passageTitle: passageTitle,
                passageBookId: passageBookId,
                passageFrom: passageFrom,
                passageTo: passageTo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingSessionsTable, ReadingSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReadingSessionsTable,
                    ReadingSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingSessionsTable,
      ReadingSession,
      $$ReadingSessionsTableFilterComposer,
      $$ReadingSessionsTableOrderingComposer,
      $$ReadingSessionsTableAnnotationComposer,
      $$ReadingSessionsTableCreateCompanionBuilder,
      $$ReadingSessionsTableUpdateCompanionBuilder,
      (
        ReadingSession,
        BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSession>,
      ),
      ReadingSession,
      PrefetchHooks Function()
    >;
typedef $$StreaksTableCreateCompanionBuilder =
    StreaksCompanion Function({
      Value<int> id,
      Value<int> current,
      Value<int> longest,
      Value<int?> lastCompletedOnEpochDay,
    });
typedef $$StreaksTableUpdateCompanionBuilder =
    StreaksCompanion Function({
      Value<int> id,
      Value<int> current,
      Value<int> longest,
      Value<int?> lastCompletedOnEpochDay,
    });

class $$StreaksTableFilterComposer
    extends Composer<_$AppDatabase, $StreaksTable> {
  $$StreaksTableFilterComposer({
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

  ColumnFilters<int> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longest => $composableBuilder(
    column: $table.longest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCompletedOnEpochDay => $composableBuilder(
    column: $table.lastCompletedOnEpochDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreaksTableOrderingComposer
    extends Composer<_$AppDatabase, $StreaksTable> {
  $$StreaksTableOrderingComposer({
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

  ColumnOrderings<int> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longest => $composableBuilder(
    column: $table.longest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCompletedOnEpochDay => $composableBuilder(
    column: $table.lastCompletedOnEpochDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreaksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreaksTable> {
  $$StreaksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get current =>
      $composableBuilder(column: $table.current, builder: (column) => column);

  GeneratedColumn<int> get longest =>
      $composableBuilder(column: $table.longest, builder: (column) => column);

  GeneratedColumn<int> get lastCompletedOnEpochDay => $composableBuilder(
    column: $table.lastCompletedOnEpochDay,
    builder: (column) => column,
  );
}

class $$StreaksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreaksTable,
          Streak,
          $$StreaksTableFilterComposer,
          $$StreaksTableOrderingComposer,
          $$StreaksTableAnnotationComposer,
          $$StreaksTableCreateCompanionBuilder,
          $$StreaksTableUpdateCompanionBuilder,
          (Streak, BaseReferences<_$AppDatabase, $StreaksTable, Streak>),
          Streak,
          PrefetchHooks Function()
        > {
  $$StreaksTableTableManager(_$AppDatabase db, $StreaksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreaksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreaksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreaksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> current = const Value.absent(),
                Value<int> longest = const Value.absent(),
                Value<int?> lastCompletedOnEpochDay = const Value.absent(),
              }) => StreaksCompanion(
                id: id,
                current: current,
                longest: longest,
                lastCompletedOnEpochDay: lastCompletedOnEpochDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> current = const Value.absent(),
                Value<int> longest = const Value.absent(),
                Value<int?> lastCompletedOnEpochDay = const Value.absent(),
              }) => StreaksCompanion.insert(
                id: id,
                current: current,
                longest: longest,
                lastCompletedOnEpochDay: lastCompletedOnEpochDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreaksTable, Streak>(table),
                  BaseReferences<_$AppDatabase, $StreaksTable, Streak>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreaksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreaksTable,
      Streak,
      $$StreaksTableFilterComposer,
      $$StreaksTableOrderingComposer,
      $$StreaksTableAnnotationComposer,
      $$StreaksTableCreateCompanionBuilder,
      $$StreaksTableUpdateCompanionBuilder,
      (Streak, BaseReferences<_$AppDatabase, $StreaksTable, Streak>),
      Streak,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String badgeId,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> badgeId,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get badgeId =>
      $composableBuilder(column: $table.badgeId, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> badgeId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                badgeId: badgeId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String badgeId,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                badgeId: badgeId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTable, Achievement>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AchievementsTable,
                    Achievement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReadingPlansTableTableManager get readingPlans =>
      $$ReadingPlansTableTableManager(_db, _db.readingPlans);
  $$DayCompletionsTableTableManager get dayCompletions =>
      $$DayCompletionsTableTableManager(_db, _db.dayCompletions);
  $$ChapterCompletionsTableTableManager get chapterCompletions =>
      $$ChapterCompletionsTableTableManager(_db, _db.chapterCompletions);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$StreaksTableTableManager get streaks =>
      $$StreaksTableTableManager(_db, _db.streaks);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
}
