// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExerciseLogCollection on Isar {
  IsarCollection<ExerciseLog> get exerciseLogs => this.collection();
}

const ExerciseLogSchema = CollectionSchema(
  name: r'ExerciseLog',
  id: 6307021889001100190,
  properties: {
    r'averageAccuracy': PropertySchema(
      id: 0,
      name: r'averageAccuracy',
      type: IsarType.double,
    ),
    r'exerciseId': PropertySchema(
      id: 1,
      name: r'exerciseId',
      type: IsarType.string,
    ),
    r'formWarnings': PropertySchema(
      id: 2,
      name: r'formWarnings',
      type: IsarType.objectList,
      target: r'FormWarning',
    ),
    r'isPremiumSession': PropertySchema(
      id: 3,
      name: r'isPremiumSession',
      type: IsarType.bool,
    ),
    r'maxAccuracy': PropertySchema(
      id: 4,
      name: r'maxAccuracy',
      type: IsarType.double,
    ),
    r'minAccuracy': PropertySchema(
      id: 5,
      name: r'minAccuracy',
      type: IsarType.double,
    ),
    r'repDetails': PropertySchema(
      id: 6,
      name: r'repDetails',
      type: IsarType.objectList,
      target: r'RepDetail',
    ),
    r'sessionDuration': PropertySchema(
      id: 7,
      name: r'sessionDuration',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'totalRepetitions': PropertySchema(
      id: 9,
      name: r'totalRepetitions',
      type: IsarType.long,
    ),
    r'videoPath': PropertySchema(
      id: 10,
      name: r'videoPath',
      type: IsarType.string,
    )
  },
  estimateSize: _exerciseLogEstimateSize,
  serialize: _exerciseLogSerialize,
  deserialize: _exerciseLogDeserialize,
  deserializeProp: _exerciseLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'exerciseId': IndexSchema(
      id: -5431545612219001672,
      name: r'exerciseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'exerciseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'RepDetail': RepDetailSchema,
    r'JointAngle': JointAngleSchema,
    r'FormWarning': FormWarningSchema
  },
  getId: _exerciseLogGetId,
  getLinks: _exerciseLogGetLinks,
  attach: _exerciseLogAttach,
  version: '3.1.0+1',
);

int _exerciseLogEstimateSize(
  ExerciseLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseId.length * 3;
  bytesCount += 3 + object.formWarnings.length * 3;
  {
    final offsets = allOffsets[FormWarning]!;
    for (var i = 0; i < object.formWarnings.length; i++) {
      final value = object.formWarnings[i];
      bytesCount += FormWarningSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.repDetails.length * 3;
  {
    final offsets = allOffsets[RepDetail]!;
    for (var i = 0; i < object.repDetails.length; i++) {
      final value = object.repDetails[i];
      bytesCount += RepDetailSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.videoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _exerciseLogSerialize(
  ExerciseLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.averageAccuracy);
  writer.writeString(offsets[1], object.exerciseId);
  writer.writeObjectList<FormWarning>(
    offsets[2],
    allOffsets,
    FormWarningSchema.serialize,
    object.formWarnings,
  );
  writer.writeBool(offsets[3], object.isPremiumSession);
  writer.writeDouble(offsets[4], object.maxAccuracy);
  writer.writeDouble(offsets[5], object.minAccuracy);
  writer.writeObjectList<RepDetail>(
    offsets[6],
    allOffsets,
    RepDetailSchema.serialize,
    object.repDetails,
  );
  writer.writeLong(offsets[7], object.sessionDuration);
  writer.writeDateTime(offsets[8], object.timestamp);
  writer.writeLong(offsets[9], object.totalRepetitions);
  writer.writeString(offsets[10], object.videoPath);
}

ExerciseLog _exerciseLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExerciseLog(
    averageAccuracy: reader.readDouble(offsets[0]),
    exerciseId: reader.readString(offsets[1]),
    formWarnings: reader.readObjectList<FormWarning>(
          offsets[2],
          FormWarningSchema.deserialize,
          allOffsets,
          FormWarning(),
        ) ??
        [],
    isPremiumSession: reader.readBoolOrNull(offsets[3]) ?? false,
    maxAccuracy: reader.readDouble(offsets[4]),
    minAccuracy: reader.readDouble(offsets[5]),
    repDetails: reader.readObjectList<RepDetail>(
          offsets[6],
          RepDetailSchema.deserialize,
          allOffsets,
          RepDetail(),
        ) ??
        [],
    sessionDuration: reader.readLong(offsets[7]),
    timestamp: reader.readDateTime(offsets[8]),
    totalRepetitions: reader.readLong(offsets[9]),
    videoPath: reader.readStringOrNull(offsets[10]),
  );
  object.id = id;
  return object;
}

P _exerciseLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readObjectList<FormWarning>(
            offset,
            FormWarningSchema.deserialize,
            allOffsets,
            FormWarning(),
          ) ??
          []) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readObjectList<RepDetail>(
            offset,
            RepDetailSchema.deserialize,
            allOffsets,
            RepDetail(),
          ) ??
          []) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exerciseLogGetId(ExerciseLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exerciseLogGetLinks(ExerciseLog object) {
  return [];
}

void _exerciseLogAttach(
    IsarCollection<dynamic> col, Id id, ExerciseLog object) {
  object.id = id;
}

extension ExerciseLogQueryWhereSort
    on QueryBuilder<ExerciseLog, ExerciseLog, QWhere> {
  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension ExerciseLogQueryWhere
    on QueryBuilder<ExerciseLog, ExerciseLog, QWhereClause> {
  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> exerciseIdEqualTo(
      String exerciseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'exerciseId',
        value: [exerciseId],
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause>
      exerciseIdNotEqualTo(String exerciseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [],
              upper: [exerciseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [exerciseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [exerciseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [],
              upper: [exerciseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> timestampEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> timestampNotEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExerciseLogQueryFilter
    on QueryBuilder<ExerciseLog, ExerciseLog, QFilterCondition> {
  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      averageAccuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      averageAccuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      averageAccuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      averageAccuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageAccuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exerciseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      formWarningsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formWarnings',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      formWarningsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formWarnings',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      formWarningsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formWarnings',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      formWarningsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formWarnings',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      formWarningsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formWarnings',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      formWarningsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formWarnings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      isPremiumSessionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPremiumSession',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      maxAccuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      maxAccuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      maxAccuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      maxAccuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxAccuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      minAccuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      minAccuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      minAccuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      minAccuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minAccuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      repDetailsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repDetails',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      repDetailsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repDetails',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      repDetailsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repDetails',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      repDetailsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repDetails',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      repDetailsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repDetails',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      repDetailsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'repDetails',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      sessionDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      sessionDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      sessionDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      sessionDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      totalRepetitionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      totalRepetitionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      totalRepetitionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      totalRepetitionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalRepetitions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'videoPath',
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'videoPath',
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      videoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoPath',
        value: '',
      ));
    });
  }
}

extension ExerciseLogQueryObject
    on QueryBuilder<ExerciseLog, ExerciseLog, QFilterCondition> {
  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      formWarningsElement(FilterQuery<FormWarning> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'formWarnings');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>
      repDetailsElement(FilterQuery<RepDetail> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'repDetails');
    });
  }
}

extension ExerciseLogQueryLinks
    on QueryBuilder<ExerciseLog, ExerciseLog, QFilterCondition> {}

extension ExerciseLogQuerySortBy
    on QueryBuilder<ExerciseLog, ExerciseLog, QSortBy> {
  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      sortByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      sortByIsPremiumSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremiumSession', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      sortByIsPremiumSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremiumSession', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByMaxAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByMaxAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByMinAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByMinAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortBySessionDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDuration', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      sortBySessionDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDuration', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      sortByTotalRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      sortByTotalRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByVideoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> sortByVideoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.desc);
    });
  }
}

extension ExerciseLogQuerySortThenBy
    on QueryBuilder<ExerciseLog, ExerciseLog, QSortThenBy> {
  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      thenByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      thenByIsPremiumSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremiumSession', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      thenByIsPremiumSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremiumSession', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByMaxAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByMaxAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByMinAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByMinAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenBySessionDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDuration', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      thenBySessionDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDuration', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      thenByTotalRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy>
      thenByTotalRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.desc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByVideoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.asc);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QAfterSortBy> thenByVideoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoPath', Sort.desc);
    });
  }
}

extension ExerciseLogQueryWhereDistinct
    on QueryBuilder<ExerciseLog, ExerciseLog, QDistinct> {
  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct>
      distinctByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageAccuracy');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct> distinctByExerciseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct>
      distinctByIsPremiumSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPremiumSession');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct> distinctByMaxAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAccuracy');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct> distinctByMinAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minAccuracy');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct>
      distinctBySessionDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionDuration');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct>
      distinctByTotalRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalRepetitions');
    });
  }

  QueryBuilder<ExerciseLog, ExerciseLog, QDistinct> distinctByVideoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoPath', caseSensitive: caseSensitive);
    });
  }
}

extension ExerciseLogQueryProperty
    on QueryBuilder<ExerciseLog, ExerciseLog, QQueryProperty> {
  QueryBuilder<ExerciseLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExerciseLog, double, QQueryOperations>
      averageAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageAccuracy');
    });
  }

  QueryBuilder<ExerciseLog, String, QQueryOperations> exerciseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseId');
    });
  }

  QueryBuilder<ExerciseLog, List<FormWarning>, QQueryOperations>
      formWarningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formWarnings');
    });
  }

  QueryBuilder<ExerciseLog, bool, QQueryOperations> isPremiumSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPremiumSession');
    });
  }

  QueryBuilder<ExerciseLog, double, QQueryOperations> maxAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAccuracy');
    });
  }

  QueryBuilder<ExerciseLog, double, QQueryOperations> minAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minAccuracy');
    });
  }

  QueryBuilder<ExerciseLog, List<RepDetail>, QQueryOperations>
      repDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repDetails');
    });
  }

  QueryBuilder<ExerciseLog, int, QQueryOperations> sessionDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionDuration');
    });
  }

  QueryBuilder<ExerciseLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<ExerciseLog, int, QQueryOperations> totalRepetitionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalRepetitions');
    });
  }

  QueryBuilder<ExerciseLog, String?, QQueryOperations> videoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoPath');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RepDetailSchema = Schema(
  name: r'RepDetail',
  id: 493210333789596072,
  properties: {
    r'accuracy': PropertySchema(
      id: 0,
      name: r'accuracy',
      type: IsarType.double,
    ),
    r'durationMs': PropertySchema(
      id: 1,
      name: r'durationMs',
      type: IsarType.long,
    ),
    r'formPerfect': PropertySchema(
      id: 2,
      name: r'formPerfect',
      type: IsarType.bool,
    ),
    r'jointAngles': PropertySchema(
      id: 3,
      name: r'jointAngles',
      type: IsarType.objectList,
      target: r'JointAngle',
    ),
    r'repNumber': PropertySchema(
      id: 4,
      name: r'repNumber',
      type: IsarType.long,
    )
  },
  estimateSize: _repDetailEstimateSize,
  serialize: _repDetailSerialize,
  deserialize: _repDetailDeserialize,
  deserializeProp: _repDetailDeserializeProp,
);

int _repDetailEstimateSize(
  RepDetail object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.jointAngles.length * 3;
  {
    final offsets = allOffsets[JointAngle]!;
    for (var i = 0; i < object.jointAngles.length; i++) {
      final value = object.jointAngles[i];
      bytesCount += JointAngleSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _repDetailSerialize(
  RepDetail object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracy);
  writer.writeLong(offsets[1], object.durationMs);
  writer.writeBool(offsets[2], object.formPerfect);
  writer.writeObjectList<JointAngle>(
    offsets[3],
    allOffsets,
    JointAngleSchema.serialize,
    object.jointAngles,
  );
  writer.writeLong(offsets[4], object.repNumber);
}

RepDetail _repDetailDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RepDetail(
    accuracy: reader.readDoubleOrNull(offsets[0]) ?? 0.0,
    durationMs: reader.readLongOrNull(offsets[1]) ?? 0,
    formPerfect: reader.readBoolOrNull(offsets[2]) ?? true,
    jointAngles: reader.readObjectList<JointAngle>(
          offsets[3],
          JointAngleSchema.deserialize,
          allOffsets,
          JointAngle(),
        ) ??
        const [],
    repNumber: reader.readLongOrNull(offsets[4]) ?? 0,
  );
  return object;
}

P _repDetailDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 3:
      return (reader.readObjectList<JointAngle>(
            offset,
            JointAngleSchema.deserialize,
            allOffsets,
            JointAngle(),
          ) ??
          const []) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RepDetailQueryFilter
    on QueryBuilder<RepDetail, RepDetail, QFilterCondition> {
  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> accuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> accuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> accuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> accuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> durationMsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      durationMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> durationMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> durationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> formPerfectEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formPerfect',
        value: value,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      jointAnglesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointAngles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      jointAnglesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointAngles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      jointAnglesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointAngles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      jointAnglesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointAngles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      jointAnglesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointAngles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      jointAnglesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointAngles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> repNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition>
      repNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> repNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> repNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RepDetailQueryObject
    on QueryBuilder<RepDetail, RepDetail, QFilterCondition> {
  QueryBuilder<RepDetail, RepDetail, QAfterFilterCondition> jointAnglesElement(
      FilterQuery<JointAngle> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'jointAngles');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const JointAngleSchema = Schema(
  name: r'JointAngle',
  id: -6791542802763547129,
  properties: {
    r'angle': PropertySchema(
      id: 0,
      name: r'angle',
      type: IsarType.double,
    ),
    r'jointName': PropertySchema(
      id: 1,
      name: r'jointName',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _jointAngleEstimateSize,
  serialize: _jointAngleSerialize,
  deserialize: _jointAngleDeserialize,
  deserializeProp: _jointAngleDeserializeProp,
);

int _jointAngleEstimateSize(
  JointAngle object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.jointName.length * 3;
  return bytesCount;
}

void _jointAngleSerialize(
  JointAngle object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.angle);
  writer.writeString(offsets[1], object.jointName);
  writer.writeDateTime(offsets[2], object.timestamp);
}

JointAngle _jointAngleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JointAngle(
    angle: reader.readDoubleOrNull(offsets[0]) ?? 0.0,
    jointName: reader.readStringOrNull(offsets[1]) ?? '',
    timestamp: reader.readDateTimeOrNull(offsets[2]),
  );
  return object;
}

P _jointAngleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension JointAngleQueryFilter
    on QueryBuilder<JointAngle, JointAngle, QFilterCondition> {
  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> angleEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'angle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> angleGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'angle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> angleLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'angle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> angleBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'angle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> jointNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jointName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition>
      jointNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jointName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> jointNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jointName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> jointNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jointName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition>
      jointNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jointName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> jointNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jointName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> jointNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jointName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> jointNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jointName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition>
      jointNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jointName',
        value: '',
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition>
      jointNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jointName',
        value: '',
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition>
      timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition>
      timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> timestampEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> timestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<JointAngle, JointAngle, QAfterFilterCondition> timestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension JointAngleQueryObject
    on QueryBuilder<JointAngle, JointAngle, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FormWarningSchema = Schema(
  name: r'FormWarning',
  id: -6323306814643881289,
  properties: {
    r'jointPosition': PropertySchema(
      id: 0,
      name: r'jointPosition',
      type: IsarType.doubleList,
    ),
    r'message': PropertySchema(
      id: 1,
      name: r'message',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'warningId': PropertySchema(
      id: 3,
      name: r'warningId',
      type: IsarType.string,
    )
  },
  estimateSize: _formWarningEstimateSize,
  serialize: _formWarningSerialize,
  deserialize: _formWarningDeserialize,
  deserializeProp: _formWarningDeserializeProp,
);

int _formWarningEstimateSize(
  FormWarning object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.jointPosition;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  bytesCount += 3 + object.message.length * 3;
  bytesCount += 3 + object.warningId.length * 3;
  return bytesCount;
}

void _formWarningSerialize(
  FormWarning object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDoubleList(offsets[0], object.jointPosition);
  writer.writeString(offsets[1], object.message);
  writer.writeDateTime(offsets[2], object.timestamp);
  writer.writeString(offsets[3], object.warningId);
}

FormWarning _formWarningDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FormWarning(
    jointPosition: reader.readDoubleList(offsets[0]),
    message: reader.readStringOrNull(offsets[1]) ?? '',
    timestamp: reader.readDateTimeOrNull(offsets[2]),
    warningId: reader.readStringOrNull(offsets[3]) ?? '',
  );
  return object;
}

P _formWarningDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleList(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FormWarningQueryFilter
    on QueryBuilder<FormWarning, FormWarning, QFilterCondition> {
  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'jointPosition',
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'jointPosition',
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jointPosition',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jointPosition',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jointPosition',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jointPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointPosition',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointPosition',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointPosition',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointPosition',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointPosition',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      jointPositionLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointPosition',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition> messageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      messageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition> messageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition> messageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'message',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      messageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition> messageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition> messageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition> messageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'message',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: '',
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'message',
        value: '',
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      timestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      timestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      timestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warningId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'warningId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'warningId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'warningId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'warningId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'warningId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'warningId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'warningId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warningId',
        value: '',
      ));
    });
  }

  QueryBuilder<FormWarning, FormWarning, QAfterFilterCondition>
      warningIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'warningId',
        value: '',
      ));
    });
  }
}

extension FormWarningQueryObject
    on QueryBuilder<FormWarning, FormWarning, QFilterCondition> {}
