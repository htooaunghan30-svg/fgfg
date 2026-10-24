// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_activity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserActivityCollection on Isar {
  IsarCollection<UserActivity> get userActivitys => this.collection();
}

const UserActivitySchema = CollectionSchema(
  name: r'UserActivity',
  id: -1674512700440994752,
  properties: {
    r'analyticsViews': PropertySchema(
      id: 0,
      name: r'analyticsViews',
      type: IsarType.long,
    ),
    r'averageAccuracy': PropertySchema(
      id: 1,
      name: r'averageAccuracy',
      type: IsarType.double,
    ),
    r'bestStreak': PropertySchema(
      id: 2,
      name: r'bestStreak',
      type: IsarType.long,
    ),
    r'bicepCurlCount': PropertySchema(
      id: 3,
      name: r'bicepCurlCount',
      type: IsarType.long,
    ),
    r'currentStreak': PropertySchema(
      id: 4,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 5,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'estimatedCalories': PropertySchema(
      id: 6,
      name: r'estimatedCalories',
      type: IsarType.double,
    ),
    r'legExtensionCount': PropertySchema(
      id: 7,
      name: r'legExtensionCount',
      type: IsarType.long,
    ),
    r'pushupCount': PropertySchema(
      id: 8,
      name: r'pushupCount',
      type: IsarType.long,
    ),
    r'shoulderPressCount': PropertySchema(
      id: 9,
      name: r'shoulderPressCount',
      type: IsarType.long,
    ),
    r'situpCount': PropertySchema(
      id: 10,
      name: r'situpCount',
      type: IsarType.long,
    ),
    r'squatCount': PropertySchema(
      id: 11,
      name: r'squatCount',
      type: IsarType.long,
    ),
    r'totalDuration': PropertySchema(
      id: 12,
      name: r'totalDuration',
      type: IsarType.long,
    ),
    r'totalRepetitions': PropertySchema(
      id: 13,
      name: r'totalRepetitions',
      type: IsarType.long,
    ),
    r'totalWorkouts': PropertySchema(
      id: 14,
      name: r'totalWorkouts',
      type: IsarType.long,
    ),
    r'videoRecordings': PropertySchema(
      id: 15,
      name: r'videoRecordings',
      type: IsarType.long,
    ),
    r'voiceCoachUses': PropertySchema(
      id: 16,
      name: r'voiceCoachUses',
      type: IsarType.long,
    ),
    r'wallSitCount': PropertySchema(
      id: 17,
      name: r'wallSitCount',
      type: IsarType.long,
    )
  },
  estimateSize: _userActivityEstimateSize,
  serialize: _userActivitySerialize,
  deserialize: _userActivityDeserialize,
  deserializeProp: _userActivityDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _userActivityGetId,
  getLinks: _userActivityGetLinks,
  attach: _userActivityAttach,
  version: '3.1.0+1',
);

int _userActivityEstimateSize(
  UserActivity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userActivitySerialize(
  UserActivity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.analyticsViews);
  writer.writeDouble(offsets[1], object.averageAccuracy);
  writer.writeLong(offsets[2], object.bestStreak);
  writer.writeLong(offsets[3], object.bicepCurlCount);
  writer.writeLong(offsets[4], object.currentStreak);
  writer.writeDateTime(offsets[5], object.date);
  writer.writeDouble(offsets[6], object.estimatedCalories);
  writer.writeLong(offsets[7], object.legExtensionCount);
  writer.writeLong(offsets[8], object.pushupCount);
  writer.writeLong(offsets[9], object.shoulderPressCount);
  writer.writeLong(offsets[10], object.situpCount);
  writer.writeLong(offsets[11], object.squatCount);
  writer.writeLong(offsets[12], object.totalDuration);
  writer.writeLong(offsets[13], object.totalRepetitions);
  writer.writeLong(offsets[14], object.totalWorkouts);
  writer.writeLong(offsets[15], object.videoRecordings);
  writer.writeLong(offsets[16], object.voiceCoachUses);
  writer.writeLong(offsets[17], object.wallSitCount);
}

UserActivity _userActivityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserActivity(
    date: reader.readDateTime(offsets[5]),
  );
  object.analyticsViews = reader.readLong(offsets[0]);
  object.averageAccuracy = reader.readDouble(offsets[1]);
  object.bestStreak = reader.readLong(offsets[2]);
  object.bicepCurlCount = reader.readLong(offsets[3]);
  object.currentStreak = reader.readLong(offsets[4]);
  object.estimatedCalories = reader.readDouble(offsets[6]);
  object.id = id;
  object.legExtensionCount = reader.readLong(offsets[7]);
  object.pushupCount = reader.readLong(offsets[8]);
  object.shoulderPressCount = reader.readLong(offsets[9]);
  object.situpCount = reader.readLong(offsets[10]);
  object.squatCount = reader.readLong(offsets[11]);
  object.totalDuration = reader.readLong(offsets[12]);
  object.totalRepetitions = reader.readLong(offsets[13]);
  object.totalWorkouts = reader.readLong(offsets[14]);
  object.videoRecordings = reader.readLong(offsets[15]);
  object.voiceCoachUses = reader.readLong(offsets[16]);
  object.wallSitCount = reader.readLong(offsets[17]);
  return object;
}

P _userActivityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userActivityGetId(UserActivity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userActivityGetLinks(UserActivity object) {
  return [];
}

void _userActivityAttach(
    IsarCollection<dynamic> col, Id id, UserActivity object) {
  object.id = id;
}

extension UserActivityQueryWhereSort
    on QueryBuilder<UserActivity, UserActivity, QWhere> {
  QueryBuilder<UserActivity, UserActivity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension UserActivityQueryWhere
    on QueryBuilder<UserActivity, UserActivity, QWhereClause> {
  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserActivityQueryFilter
    on QueryBuilder<UserActivity, UserActivity, QFilterCondition> {
  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      analyticsViewsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'analyticsViews',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      analyticsViewsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'analyticsViews',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      analyticsViewsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'analyticsViews',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      analyticsViewsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'analyticsViews',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bicepCurlCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bicepCurlCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bicepCurlCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bicepCurlCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bicepCurlCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bicepCurlCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      bicepCurlCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bicepCurlCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      estimatedCaloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      estimatedCaloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      estimatedCaloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      estimatedCaloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      legExtensionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'legExtensionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      legExtensionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'legExtensionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      legExtensionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'legExtensionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      legExtensionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'legExtensionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      pushupCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pushupCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      pushupCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pushupCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      pushupCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pushupCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      pushupCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pushupCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      shoulderPressCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shoulderPressCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      shoulderPressCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shoulderPressCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      shoulderPressCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shoulderPressCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      shoulderPressCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shoulderPressCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      situpCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'situpCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      situpCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'situpCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      situpCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'situpCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      situpCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'situpCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      squatCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'squatCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      squatCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'squatCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      squatCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'squatCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      squatCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'squatCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalRepetitionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
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

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalWorkoutsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalWorkouts',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalWorkoutsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalWorkouts',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalWorkoutsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalWorkouts',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      totalWorkoutsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalWorkouts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      videoRecordingsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoRecordings',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      videoRecordingsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoRecordings',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      videoRecordingsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoRecordings',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      videoRecordingsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoRecordings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      voiceCoachUsesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voiceCoachUses',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      voiceCoachUsesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voiceCoachUses',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      voiceCoachUsesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voiceCoachUses',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      voiceCoachUsesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voiceCoachUses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      wallSitCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wallSitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      wallSitCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wallSitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      wallSitCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wallSitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterFilterCondition>
      wallSitCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wallSitCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserActivityQueryObject
    on QueryBuilder<UserActivity, UserActivity, QFilterCondition> {}

extension UserActivityQueryLinks
    on QueryBuilder<UserActivity, UserActivity, QFilterCondition> {}

extension UserActivityQuerySortBy
    on QueryBuilder<UserActivity, UserActivity, QSortBy> {
  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByAnalyticsViews() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsViews', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByAnalyticsViewsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsViews', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByBicepCurlCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicepCurlCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByBicepCurlCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicepCurlCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByEstimatedCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCalories', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByEstimatedCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCalories', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByLegExtensionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legExtensionCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByLegExtensionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legExtensionCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByPushupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushupCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByPushupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushupCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByShoulderPressCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shoulderPressCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByShoulderPressCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shoulderPressCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortBySitupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situpCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortBySitupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situpCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortBySquatCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'squatCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortBySquatCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'squatCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByTotalDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByTotalDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByTotalRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByTotalRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByTotalWorkouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByTotalWorkoutsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByVideoRecordings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoRecordings', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByVideoRecordingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoRecordings', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByVoiceCoachUses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCoachUses', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByVoiceCoachUsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCoachUses', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> sortByWallSitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallSitCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      sortByWallSitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallSitCount', Sort.desc);
    });
  }
}

extension UserActivityQuerySortThenBy
    on QueryBuilder<UserActivity, UserActivity, QSortThenBy> {
  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByAnalyticsViews() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsViews', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByAnalyticsViewsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'analyticsViews', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByAverageAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAccuracy', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByBicepCurlCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicepCurlCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByBicepCurlCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicepCurlCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByEstimatedCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCalories', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByEstimatedCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCalories', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByLegExtensionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legExtensionCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByLegExtensionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legExtensionCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByPushupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushupCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByPushupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushupCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByShoulderPressCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shoulderPressCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByShoulderPressCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shoulderPressCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenBySitupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situpCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenBySitupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'situpCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenBySquatCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'squatCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenBySquatCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'squatCount', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByTotalDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByTotalDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDuration', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByTotalRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByTotalRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRepetitions', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByTotalWorkouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByTotalWorkoutsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWorkouts', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByVideoRecordings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoRecordings', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByVideoRecordingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'videoRecordings', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByVoiceCoachUses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCoachUses', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByVoiceCoachUsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceCoachUses', Sort.desc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy> thenByWallSitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallSitCount', Sort.asc);
    });
  }

  QueryBuilder<UserActivity, UserActivity, QAfterSortBy>
      thenByWallSitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wallSitCount', Sort.desc);
    });
  }
}

extension UserActivityQueryWhereDistinct
    on QueryBuilder<UserActivity, UserActivity, QDistinct> {
  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByAnalyticsViews() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'analyticsViews');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByAverageAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageAccuracy');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct> distinctByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestStreak');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByBicepCurlCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bicepCurlCount');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByEstimatedCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedCalories');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByLegExtensionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'legExtensionCount');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct> distinctByPushupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pushupCount');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByShoulderPressCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shoulderPressCount');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct> distinctBySitupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'situpCount');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct> distinctBySquatCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'squatCount');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByTotalDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDuration');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByTotalRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalRepetitions');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByTotalWorkouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalWorkouts');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByVideoRecordings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoRecordings');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct>
      distinctByVoiceCoachUses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceCoachUses');
    });
  }

  QueryBuilder<UserActivity, UserActivity, QDistinct> distinctByWallSitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wallSitCount');
    });
  }
}

extension UserActivityQueryProperty
    on QueryBuilder<UserActivity, UserActivity, QQueryProperty> {
  QueryBuilder<UserActivity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> analyticsViewsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'analyticsViews');
    });
  }

  QueryBuilder<UserActivity, double, QQueryOperations>
      averageAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageAccuracy');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> bestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestStreak');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> bicepCurlCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bicepCurlCount');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<UserActivity, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<UserActivity, double, QQueryOperations>
      estimatedCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedCalories');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations>
      legExtensionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'legExtensionCount');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> pushupCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pushupCount');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations>
      shoulderPressCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shoulderPressCount');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> situpCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'situpCount');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> squatCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'squatCount');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> totalDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDuration');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> totalRepetitionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalRepetitions');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> totalWorkoutsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalWorkouts');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> videoRecordingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoRecordings');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> voiceCoachUsesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceCoachUses');
    });
  }

  QueryBuilder<UserActivity, int, QQueryOperations> wallSitCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wallSitCount');
    });
  }
}
