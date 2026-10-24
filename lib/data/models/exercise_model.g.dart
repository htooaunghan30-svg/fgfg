// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExerciseModelCollection on Isar {
  IsarCollection<ExerciseModel> get exerciseModels => this.collection();
}

const ExerciseModelSchema = CollectionSchema(
  name: r'ExerciseModel',
  id: -3488639855911673103,
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
    r'formChecks': PropertySchema(
      id: 2,
      name: r'formChecks',
      type: IsarType.objectList,
      target: r'FormCheck',
    ),
    r'lastPerformed': PropertySchema(
      id: 3,
      name: r'lastPerformed',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'repLogic': PropertySchema(
      id: 5,
      name: r'repLogic',
      type: IsarType.object,
      target: r'RepLogic',
    ),
    r'totalReps': PropertySchema(
      id: 6,
      name: r'totalReps',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 7,
      name: r'type',
      type: IsarType.string,
    ),
    r'viewRequired': PropertySchema(
      id: 8,
      name: r'viewRequired',
      type: IsarType.string,
    )
  },
  estimateSize: _exerciseModelEstimateSize,
  serialize: _exerciseModelSerialize,
  deserialize: _exerciseModelDeserialize,
  deserializeProp: _exerciseModelDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {
    r'RepLogic': RepLogicSchema,
    r'Phase': PhaseSchema,
    r'HoldCondition': HoldConditionSchema,
    r'FormCheck': FormCheckSchema
  },
  getId: _exerciseModelGetId,
  getLinks: _exerciseModelGetLinks,
  attach: _exerciseModelAttach,
  version: '3.1.0+1',
);

int _exerciseModelEstimateSize(
  ExerciseModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseId.length * 3;
  bytesCount += 3 + object.formChecks.length * 3;
  {
    final offsets = allOffsets[FormCheck]!;
    for (var i = 0; i < object.formChecks.length; i++) {
      final value = object.formChecks[i];
      bytesCount += FormCheckSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 +
      RepLogicSchema.estimateSize(
          object.repLogic, allOffsets[RepLogic]!, allOffsets);
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.viewRequired.length * 3;
  return bytesCount;
}

void _exerciseModelSerialize(
  ExerciseModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.averageAccuracy);
  writer.writeString(offsets[1], object.exerciseId);
  writer.writeObjectList<FormCheck>(
    offsets[2],
    allOffsets,
    FormCheckSchema.serialize,
    object.formChecks,
  );
  writer.writeDateTime(offsets[3], object.lastPerformed);
  writer.writeString(offsets[4], object.name);
  writer.writeObject<RepLogic>(
    offsets[5],
    allOffsets,
    RepLogicSchema.serialize,
    object.repLogic,
  );
  writer.writeLong(offsets[6], object.totalReps);
  writer.writeString(offsets[7], object.type);
  writer.writeString(offsets[8], object.viewRequired);
}

ExerciseModel _exerciseModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExerciseModel(
    averageAccuracy: reader.readDoubleOrNull(offsets[0]) ?? 0.0,
    exerciseId: reader.readString(offsets[1]),
    formChecks: reader.readObjectList<FormCheck>(
          offsets[2],
          FormCheckSchema.deserialize,
          allOffsets,
          FormCheck(),
        ) ??
        [],
    lastPerformed: reader.readDateTime(offsets[3]),
    name: reader.readString(offsets[4]),
    repLogic: reader.readObjectOrNull<RepLogic>(
          offsets[5],
          RepLogicSchema.deserialize,
          allOffsets,
        ) ??
        RepLogic(),
    totalReps: reader.readLongOrNull(offsets[6]) ?? 0,
    type: reader.readString(offsets[7]),
    viewRequired: reader.readString(offsets[8]),
  );
  object.id = id;
  return object;
}

P _exerciseModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readObjectList<FormCheck>(
            offset,
            FormCheckSchema.deserialize,
            allOffsets,
            FormCheck(),
          ) ??
          []) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readObjectOrNull<RepLogic>(
            offset,
            RepLogicSchema.deserialize,
            allOffsets,
          ) ??
          RepLogic()) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exerciseModelGetId(ExerciseModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exerciseModelGetLinks(ExerciseModel object) {
  return [];
}

void _exerciseModelAttach(
    IsarCollection<dynamic> col, Id id, ExerciseModel object) {
  object.id = id;
}

extension ExerciseModelQueryWhereSort
    on QueryBuilder<ExerciseModel, ExerciseModel, QWhere> {
  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExerciseModelQueryWhere
    on QueryBuilder<ExerciseModel, ExerciseModel, QWhereClause> {
  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhereClause>
      exerciseIdEqualTo(String exerciseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'exerciseId',
        value: [exerciseId],
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterWhereClause>
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
}

extension ExerciseModelQueryFilter
    on QueryBuilder<ExerciseModel, ExerciseModel, QFilterCondition> {
  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      exerciseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      exerciseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      formChecksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formChecks',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      formChecksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formChecks',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      formChecksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formChecks',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      formChecksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formChecks',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      formChecksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formChecks',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      formChecksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'formChecks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      lastPerformedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPerformed',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      lastPerformedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPerformed',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      lastPerformedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPerformed',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      lastPerformedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPerformed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      totalRepsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalReps',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      totalRepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalReps',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      totalRepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalReps',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      totalRepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalReps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewRequired',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'viewRequired',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'viewRequired',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'viewRequired',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'viewRequired',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'viewRequired',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'viewRequired',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'viewRequired',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewRequired',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      viewRequiredIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'viewRequired',
        value: '',
      ));
    });
  }
}

extension ExerciseModelQueryObject
    on QueryBuilder<ExerciseModel, ExerciseModel, QFilterCondition> {
  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition>
      formChecksElement(FilterQuery<FormCheck> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'formChecks');
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterFilterCondition> repLogic(
      FilterQuery<RepLogic> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'repLogic');
    });
  }
}

extension ExerciseModelQueryLinks
    on QueryBuilder<ExerciseModel, ExerciseModel, QFilterCondition> {}

extension ExerciseModelQuerySortBy
    on QueryBuilder<ExerciseModel, ExerciseModel, QSortBy> {
  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> sortByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByLastPerformed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformed', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByLastPerformedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformed', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> sortByTotalReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReps', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByTotalRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReps', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByViewRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewRequired', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      sortByViewRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewRequired', Sort.desc);
    });
  }
}

extension ExerciseModelQuerySortThenBy
    on QueryBuilder<ExerciseModel, ExerciseModel, QSortThenBy> {
  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByLastPerformed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformed', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByLastPerformedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPerformed', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenByTotalReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReps', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByTotalRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReps', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByViewRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewRequired', Sort.asc);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QAfterSortBy>
      thenByViewRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewRequired', Sort.desc);
    });
  }
}

extension ExerciseModelQueryWhereDistinct
    on QueryBuilder<ExerciseModel, ExerciseModel, QDistinct> {
  QueryBuilder<ExerciseModel, ExerciseModel, QDistinct>
      distinctByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageAccuracy');
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QDistinct> distinctByExerciseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QDistinct>
      distinctByLastPerformed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPerformed');
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QDistinct> distinctByTotalReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalReps');
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseModel, ExerciseModel, QDistinct> distinctByViewRequired(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewRequired', caseSensitive: caseSensitive);
    });
  }
}

extension ExerciseModelQueryProperty
    on QueryBuilder<ExerciseModel, ExerciseModel, QQueryProperty> {
  QueryBuilder<ExerciseModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExerciseModel, double, QQueryOperations>
      averageAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageAccuracy');
    });
  }

  QueryBuilder<ExerciseModel, String, QQueryOperations> exerciseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseId');
    });
  }

  QueryBuilder<ExerciseModel, List<FormCheck>, QQueryOperations>
      formChecksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formChecks');
    });
  }

  QueryBuilder<ExerciseModel, DateTime, QQueryOperations>
      lastPerformedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPerformed');
    });
  }

  QueryBuilder<ExerciseModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ExerciseModel, RepLogic, QQueryOperations> repLogicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repLogic');
    });
  }

  QueryBuilder<ExerciseModel, int, QQueryOperations> totalRepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalReps');
    });
  }

  QueryBuilder<ExerciseModel, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<ExerciseModel, String, QQueryOperations> viewRequiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewRequired');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RepLogicSchema = Schema(
  name: r'RepLogic',
  id: 5980383979958290810,
  properties: {
    r'countType': PropertySchema(
      id: 0,
      name: r'countType',
      type: IsarType.string,
    ),
    r'holdCondition': PropertySchema(
      id: 1,
      name: r'holdCondition',
      type: IsarType.object,
      target: r'HoldCondition',
    ),
    r'phase1Eccentric': PropertySchema(
      id: 2,
      name: r'phase1Eccentric',
      type: IsarType.object,
      target: r'Phase',
    ),
    r'phase2Concentric': PropertySchema(
      id: 3,
      name: r'phase2Concentric',
      type: IsarType.object,
      target: r'Phase',
    ),
    r'primaryJoint': PropertySchema(
      id: 4,
      name: r'primaryJoint',
      type: IsarType.string,
    )
  },
  estimateSize: _repLogicEstimateSize,
  serialize: _repLogicSerialize,
  deserialize: _repLogicDeserialize,
  deserializeProp: _repLogicDeserializeProp,
);

int _repLogicEstimateSize(
  RepLogic object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.countType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.holdCondition;
    if (value != null) {
      bytesCount += 3 +
          HoldConditionSchema.estimateSize(
              value, allOffsets[HoldCondition]!, allOffsets);
    }
  }
  {
    final value = object.phase1Eccentric;
    if (value != null) {
      bytesCount +=
          3 + PhaseSchema.estimateSize(value, allOffsets[Phase]!, allOffsets);
    }
  }
  {
    final value = object.phase2Concentric;
    if (value != null) {
      bytesCount +=
          3 + PhaseSchema.estimateSize(value, allOffsets[Phase]!, allOffsets);
    }
  }
  bytesCount += 3 + object.primaryJoint.length * 3;
  return bytesCount;
}

void _repLogicSerialize(
  RepLogic object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.countType);
  writer.writeObject<HoldCondition>(
    offsets[1],
    allOffsets,
    HoldConditionSchema.serialize,
    object.holdCondition,
  );
  writer.writeObject<Phase>(
    offsets[2],
    allOffsets,
    PhaseSchema.serialize,
    object.phase1Eccentric,
  );
  writer.writeObject<Phase>(
    offsets[3],
    allOffsets,
    PhaseSchema.serialize,
    object.phase2Concentric,
  );
  writer.writeString(offsets[4], object.primaryJoint);
}

RepLogic _repLogicDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RepLogic(
    countType: reader.readStringOrNull(offsets[0]),
    holdCondition: reader.readObjectOrNull<HoldCondition>(
      offsets[1],
      HoldConditionSchema.deserialize,
      allOffsets,
    ),
    phase1Eccentric: reader.readObjectOrNull<Phase>(
      offsets[2],
      PhaseSchema.deserialize,
      allOffsets,
    ),
    phase2Concentric: reader.readObjectOrNull<Phase>(
      offsets[3],
      PhaseSchema.deserialize,
      allOffsets,
    ),
    primaryJoint: reader.readStringOrNull(offsets[4]) ?? 'knee',
  );
  return object;
}

P _repLogicDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<HoldCondition>(
        offset,
        HoldConditionSchema.deserialize,
        allOffsets,
      )) as P;
    case 2:
      return (reader.readObjectOrNull<Phase>(
        offset,
        PhaseSchema.deserialize,
        allOffsets,
      )) as P;
    case 3:
      return (reader.readObjectOrNull<Phase>(
        offset,
        PhaseSchema.deserialize,
        allOffsets,
      )) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? 'knee') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RepLogicQueryFilter
    on QueryBuilder<RepLogic, RepLogic, QFilterCondition> {
  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'countType',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'countType',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'countType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'countType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'countType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'countType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'countType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'countType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'countType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> countTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countType',
        value: '',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      countTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'countType',
        value: '',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      holdConditionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'holdCondition',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      holdConditionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'holdCondition',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      phase1EccentricIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phase1Eccentric',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      phase1EccentricIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phase1Eccentric',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      phase2ConcentricIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phase2Concentric',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      phase2ConcentricIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phase2Concentric',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> primaryJointEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      primaryJointGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> primaryJointLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> primaryJointBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryJoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      primaryJointStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> primaryJointEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> primaryJointContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> primaryJointMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryJoint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      primaryJointIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryJoint',
        value: '',
      ));
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition>
      primaryJointIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryJoint',
        value: '',
      ));
    });
  }
}

extension RepLogicQueryObject
    on QueryBuilder<RepLogic, RepLogic, QFilterCondition> {
  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> holdCondition(
      FilterQuery<HoldCondition> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'holdCondition');
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> phase1Eccentric(
      FilterQuery<Phase> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'phase1Eccentric');
    });
  }

  QueryBuilder<RepLogic, RepLogic, QAfterFilterCondition> phase2Concentric(
      FilterQuery<Phase> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'phase2Concentric');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PhaseSchema = Schema(
  name: r'Phase',
  id: -2090859306872267,
  properties: {
    r'condition': PropertySchema(
      id: 0,
      name: r'condition',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'threshold': PropertySchema(
      id: 2,
      name: r'threshold',
      type: IsarType.double,
    )
  },
  estimateSize: _phaseEstimateSize,
  serialize: _phaseSerialize,
  deserialize: _phaseDeserialize,
  deserializeProp: _phaseDeserializeProp,
);

int _phaseEstimateSize(
  Phase object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.condition.length * 3;
  bytesCount += 3 + object.description.length * 3;
  return bytesCount;
}

void _phaseSerialize(
  Phase object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.condition);
  writer.writeString(offsets[1], object.description);
  writer.writeDouble(offsets[2], object.threshold);
}

Phase _phaseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Phase(
    condition: reader.readStringOrNull(offsets[0]) ?? '',
    description: reader.readStringOrNull(offsets[1]) ?? '',
    threshold: reader.readDoubleOrNull(offsets[2]) ?? 0.0,
  );
  return object;
}

P _phaseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PhaseQueryFilter on QueryBuilder<Phase, Phase, QFilterCondition> {
  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'condition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'condition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'condition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'condition',
        value: '',
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> conditionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'condition',
        value: '',
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> thresholdEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> thresholdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'threshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> thresholdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'threshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Phase, Phase, QAfterFilterCondition> thresholdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'threshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension PhaseQueryObject on QueryBuilder<Phase, Phase, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const HoldConditionSchema = Schema(
  name: r'HoldCondition',
  id: 6153320220915920961,
  properties: {
    r'maxBackAngle': PropertySchema(
      id: 0,
      name: r'maxBackAngle',
      type: IsarType.double,
    ),
    r'maxKneeAngle': PropertySchema(
      id: 1,
      name: r'maxKneeAngle',
      type: IsarType.double,
    ),
    r'minBackAngle': PropertySchema(
      id: 2,
      name: r'minBackAngle',
      type: IsarType.double,
    ),
    r'minKneeAngle': PropertySchema(
      id: 3,
      name: r'minKneeAngle',
      type: IsarType.double,
    )
  },
  estimateSize: _holdConditionEstimateSize,
  serialize: _holdConditionSerialize,
  deserialize: _holdConditionDeserialize,
  deserializeProp: _holdConditionDeserializeProp,
);

int _holdConditionEstimateSize(
  HoldCondition object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _holdConditionSerialize(
  HoldCondition object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.maxBackAngle);
  writer.writeDouble(offsets[1], object.maxKneeAngle);
  writer.writeDouble(offsets[2], object.minBackAngle);
  writer.writeDouble(offsets[3], object.minKneeAngle);
}

HoldCondition _holdConditionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HoldCondition(
    maxBackAngle: reader.readDoubleOrNull(offsets[0]),
    maxKneeAngle: reader.readDoubleOrNull(offsets[1]),
    minBackAngle: reader.readDoubleOrNull(offsets[2]),
    minKneeAngle: reader.readDoubleOrNull(offsets[3]),
  );
  return object;
}

P _holdConditionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension HoldConditionQueryFilter
    on QueryBuilder<HoldCondition, HoldCondition, QFilterCondition> {
  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxBackAngleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxBackAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxBackAngleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxBackAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxBackAngleEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxBackAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxBackAngleGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxBackAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxBackAngleLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxBackAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxBackAngleBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxBackAngle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxKneeAngleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxKneeAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxKneeAngleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxKneeAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxKneeAngleEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxKneeAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxKneeAngleGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxKneeAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxKneeAngleLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxKneeAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      maxKneeAngleBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxKneeAngle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minBackAngleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'minBackAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minBackAngleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'minBackAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minBackAngleEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minBackAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minBackAngleGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minBackAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minBackAngleLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minBackAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minBackAngleBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minBackAngle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minKneeAngleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'minKneeAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minKneeAngleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'minKneeAngle',
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minKneeAngleEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minKneeAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minKneeAngleGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minKneeAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minKneeAngleLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minKneeAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HoldCondition, HoldCondition, QAfterFilterCondition>
      minKneeAngleBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minKneeAngle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension HoldConditionQueryObject
    on QueryBuilder<HoldCondition, HoldCondition, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FormCheckSchema = Schema(
  name: r'FormCheck',
  id: -6679204308917949599,
  properties: {
    r'checkType': PropertySchema(
      id: 0,
      name: r'checkType',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'joints': PropertySchema(
      id: 2,
      name: r'joints',
      type: IsarType.stringList,
    ),
    r'jointsPair': PropertySchema(
      id: 3,
      name: r'jointsPair',
      type: IsarType.stringList,
    ),
    r'maxAngle': PropertySchema(
      id: 4,
      name: r'maxAngle',
      type: IsarType.double,
    ),
    r'minAngle': PropertySchema(
      id: 5,
      name: r'minAngle',
      type: IsarType.double,
    ),
    r'targetJoint': PropertySchema(
      id: 6,
      name: r'targetJoint',
      type: IsarType.string,
    ),
    r'tolerance': PropertySchema(
      id: 7,
      name: r'tolerance',
      type: IsarType.double,
    ),
    r'warningMessage': PropertySchema(
      id: 8,
      name: r'warningMessage',
      type: IsarType.string,
    )
  },
  estimateSize: _formCheckEstimateSize,
  serialize: _formCheckSerialize,
  deserialize: _formCheckDeserialize,
  deserializeProp: _formCheckDeserializeProp,
);

int _formCheckEstimateSize(
  FormCheck object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.checkType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.joints.length * 3;
  {
    for (var i = 0; i < object.joints.length; i++) {
      final value = object.joints[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final list = object.jointsPair;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.targetJoint;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.warningMessage.length * 3;
  return bytesCount;
}

void _formCheckSerialize(
  FormCheck object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.checkType);
  writer.writeString(offsets[1], object.id);
  writer.writeStringList(offsets[2], object.joints);
  writer.writeStringList(offsets[3], object.jointsPair);
  writer.writeDouble(offsets[4], object.maxAngle);
  writer.writeDouble(offsets[5], object.minAngle);
  writer.writeString(offsets[6], object.targetJoint);
  writer.writeDouble(offsets[7], object.tolerance);
  writer.writeString(offsets[8], object.warningMessage);
}

FormCheck _formCheckDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FormCheck(
    checkType: reader.readStringOrNull(offsets[0]),
    id: reader.readStringOrNull(offsets[1]) ?? '',
    joints: reader.readStringList(offsets[2]) ?? const [],
    jointsPair: reader.readStringList(offsets[3]),
    maxAngle: reader.readDoubleOrNull(offsets[4]) ?? 0.0,
    minAngle: reader.readDoubleOrNull(offsets[5]) ?? 0.0,
    targetJoint: reader.readStringOrNull(offsets[6]),
    tolerance: reader.readDoubleOrNull(offsets[7]),
    warningMessage: reader.readStringOrNull(offsets[8]) ?? '',
  );
  return object;
}

P _formCheckDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 5:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FormCheckQueryFilter
    on QueryBuilder<FormCheck, FormCheck, QFilterCondition> {
  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkType',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      checkTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkType',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      checkTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'checkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'checkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'checkType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'checkType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> checkTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkType',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      checkTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'checkType',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'joints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'joints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'joints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'joints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'joints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'joints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'joints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'joints',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'joints',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'joints',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> jointsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'joints',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> jointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'joints',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> jointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'joints',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'joints',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'joints',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> jointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'joints',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> jointsPairIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'jointsPair',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'jointsPair',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jointsPair',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jointsPair',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jointsPair',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jointsPair',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jointsPair',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jointsPair',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jointsPair',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jointsPair',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jointsPair',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jointsPair',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointsPair',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointsPair',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointsPair',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointsPair',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointsPair',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      jointsPairLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'jointsPair',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> maxAngleEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> maxAngleGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> maxAngleLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> maxAngleBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxAngle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> minAngleEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> minAngleGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> minAngleLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minAngle',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> minAngleBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minAngle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      targetJointIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetJoint',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      targetJointIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetJoint',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> targetJointEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      targetJointGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> targetJointLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> targetJointBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetJoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      targetJointStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> targetJointEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> targetJointContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetJoint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> targetJointMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetJoint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      targetJointIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetJoint',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      targetJointIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetJoint',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> toleranceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tolerance',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      toleranceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tolerance',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> toleranceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tolerance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      toleranceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tolerance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> toleranceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tolerance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition> toleranceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tolerance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warningMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'warningMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'warningMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'warningMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'warningMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'warningMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'warningMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'warningMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warningMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<FormCheck, FormCheck, QAfterFilterCondition>
      warningMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'warningMessage',
        value: '',
      ));
    });
  }
}

extension FormCheckQueryObject
    on QueryBuilder<FormCheck, FormCheck, QFilterCondition> {}
