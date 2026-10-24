// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_achievement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBadgeAchievementCollection on Isar {
  IsarCollection<BadgeAchievement> get badgeAchievements => this.collection();
}

const BadgeAchievementSchema = CollectionSchema(
  name: r'BadgeAchievement',
  id: -3860904785607112792,
  properties: {
    r'badgeId': PropertySchema(
      id: 0,
      name: r'badgeId',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'iconPath': PropertySchema(
      id: 2,
      name: r'iconPath',
      type: IsarType.string,
    ),
    r'isUnlocked': PropertySchema(
      id: 3,
      name: r'isUnlocked',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 5,
      name: r'progress',
      type: IsarType.long,
    ),
    r'requirement': PropertySchema(
      id: 6,
      name: r'requirement',
      type: IsarType.long,
    ),
    r'tier': PropertySchema(
      id: 7,
      name: r'tier',
      type: IsarType.byte,
      enumMap: _BadgeAchievementtierEnumValueMap,
    ),
    r'unlockedAt': PropertySchema(
      id: 8,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    ),
    r'unlockedFor': PropertySchema(
      id: 9,
      name: r'unlockedFor',
      type: IsarType.string,
    )
  },
  estimateSize: _badgeAchievementEstimateSize,
  serialize: _badgeAchievementSerialize,
  deserialize: _badgeAchievementDeserialize,
  deserializeProp: _badgeAchievementDeserializeProp,
  idName: r'id',
  indexes: {
    r'badgeId': IndexSchema(
      id: 2632729407329682508,
      name: r'badgeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'badgeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _badgeAchievementGetId,
  getLinks: _badgeAchievementGetLinks,
  attach: _badgeAchievementAttach,
  version: '3.1.0+1',
);

int _badgeAchievementEstimateSize(
  BadgeAchievement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.badgeId.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.iconPath.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.unlockedFor.length * 3;
  return bytesCount;
}

void _badgeAchievementSerialize(
  BadgeAchievement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.badgeId);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.iconPath);
  writer.writeBool(offsets[3], object.isUnlocked);
  writer.writeString(offsets[4], object.name);
  writer.writeLong(offsets[5], object.progress);
  writer.writeLong(offsets[6], object.requirement);
  writer.writeByte(offsets[7], object.tier.index);
  writer.writeDateTime(offsets[8], object.unlockedAt);
  writer.writeString(offsets[9], object.unlockedFor);
}

BadgeAchievement _badgeAchievementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BadgeAchievement(
    badgeId: reader.readString(offsets[0]),
    description: reader.readString(offsets[1]),
    iconPath: reader.readString(offsets[2]),
    name: reader.readString(offsets[4]),
    progress: reader.readLong(offsets[5]),
    requirement: reader.readLong(offsets[6]),
    tier:
        _BadgeAchievementtierValueEnumMap[reader.readByteOrNull(offsets[7])] ??
            BadgeTier.bronze,
    unlockedAt: reader.readDateTime(offsets[8]),
    unlockedFor: reader.readString(offsets[9]),
  );
  object.id = id;
  return object;
}

P _badgeAchievementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (_BadgeAchievementtierValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BadgeTier.bronze) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BadgeAchievementtierEnumValueMap = {
  'bronze': 0,
  'silver': 1,
  'gold': 2,
  'platinum': 3,
};
const _BadgeAchievementtierValueEnumMap = {
  0: BadgeTier.bronze,
  1: BadgeTier.silver,
  2: BadgeTier.gold,
  3: BadgeTier.platinum,
};

Id _badgeAchievementGetId(BadgeAchievement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _badgeAchievementGetLinks(BadgeAchievement object) {
  return [];
}

void _badgeAchievementAttach(
    IsarCollection<dynamic> col, Id id, BadgeAchievement object) {
  object.id = id;
}

extension BadgeAchievementByIndex on IsarCollection<BadgeAchievement> {
  Future<BadgeAchievement?> getByBadgeId(String badgeId) {
    return getByIndex(r'badgeId', [badgeId]);
  }

  BadgeAchievement? getByBadgeIdSync(String badgeId) {
    return getByIndexSync(r'badgeId', [badgeId]);
  }

  Future<bool> deleteByBadgeId(String badgeId) {
    return deleteByIndex(r'badgeId', [badgeId]);
  }

  bool deleteByBadgeIdSync(String badgeId) {
    return deleteByIndexSync(r'badgeId', [badgeId]);
  }

  Future<List<BadgeAchievement?>> getAllByBadgeId(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'badgeId', values);
  }

  List<BadgeAchievement?> getAllByBadgeIdSync(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'badgeId', values);
  }

  Future<int> deleteAllByBadgeId(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'badgeId', values);
  }

  int deleteAllByBadgeIdSync(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'badgeId', values);
  }

  Future<Id> putByBadgeId(BadgeAchievement object) {
    return putByIndex(r'badgeId', object);
  }

  Id putByBadgeIdSync(BadgeAchievement object, {bool saveLinks = true}) {
    return putByIndexSync(r'badgeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBadgeId(List<BadgeAchievement> objects) {
    return putAllByIndex(r'badgeId', objects);
  }

  List<Id> putAllByBadgeIdSync(List<BadgeAchievement> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'badgeId', objects, saveLinks: saveLinks);
  }
}

extension BadgeAchievementQueryWhereSort
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QWhere> {
  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BadgeAchievementQueryWhere
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QWhereClause> {
  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhereClause> idBetween(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhereClause>
      badgeIdEqualTo(String badgeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'badgeId',
        value: [badgeId],
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterWhereClause>
      badgeIdNotEqualTo(String badgeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [],
              upper: [badgeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [badgeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [badgeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [],
              upper: [badgeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BadgeAchievementQueryFilter
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QFilterCondition> {
  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'badgeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'badgeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeId',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      badgeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'badgeId',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionEqualTo(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionGreaterThan(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionLessThan(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionBetween(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionStartsWith(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionEndsWith(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      iconPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconPath',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      isUnlockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUnlocked',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
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

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      progressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      progressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      progressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      progressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      requirementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requirement',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      requirementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requirement',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      requirementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requirement',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      requirementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requirement',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      tierEqualTo(BadgeTier value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tier',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      tierGreaterThan(
    BadgeTier value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tier',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      tierLessThan(
    BadgeTier value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tier',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      tierBetween(
    BadgeTier lower,
    BadgeTier upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedFor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockedFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockedFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockedFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockedFor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedFor',
        value: '',
      ));
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterFilterCondition>
      unlockedForIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockedFor',
        value: '',
      ));
    });
  }
}

extension BadgeAchievementQueryObject
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QFilterCondition> {}

extension BadgeAchievementQueryLinks
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QFilterCondition> {}

extension BadgeAchievementQuerySortBy
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QSortBy> {
  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByBadgeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByBadgeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByIconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByIconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByRequirement() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirement', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByRequirementDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirement', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy> sortByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByUnlockedFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedFor', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      sortByUnlockedForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedFor', Sort.desc);
    });
  }
}

extension BadgeAchievementQuerySortThenBy
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QSortThenBy> {
  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByBadgeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByBadgeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByIconPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByIconPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconPath', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByRequirement() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirement', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByRequirementDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirement', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy> thenByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByUnlockedFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedFor', Sort.asc);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QAfterSortBy>
      thenByUnlockedForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedFor', Sort.desc);
    });
  }
}

extension BadgeAchievementQueryWhereDistinct
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct> {
  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct> distinctByBadgeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'badgeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct>
      distinctByIconPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct>
      distinctByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUnlocked');
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct>
      distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct>
      distinctByRequirement() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requirement');
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct> distinctByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tier');
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct>
      distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }

  QueryBuilder<BadgeAchievement, BadgeAchievement, QDistinct>
      distinctByUnlockedFor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedFor', caseSensitive: caseSensitive);
    });
  }
}

extension BadgeAchievementQueryProperty
    on QueryBuilder<BadgeAchievement, BadgeAchievement, QQueryProperty> {
  QueryBuilder<BadgeAchievement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BadgeAchievement, String, QQueryOperations> badgeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'badgeId');
    });
  }

  QueryBuilder<BadgeAchievement, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<BadgeAchievement, String, QQueryOperations> iconPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconPath');
    });
  }

  QueryBuilder<BadgeAchievement, bool, QQueryOperations> isUnlockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUnlocked');
    });
  }

  QueryBuilder<BadgeAchievement, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<BadgeAchievement, int, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<BadgeAchievement, int, QQueryOperations> requirementProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requirement');
    });
  }

  QueryBuilder<BadgeAchievement, BadgeTier, QQueryOperations> tierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tier');
    });
  }

  QueryBuilder<BadgeAchievement, DateTime, QQueryOperations>
      unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }

  QueryBuilder<BadgeAchievement, String, QQueryOperations>
      unlockedForProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedFor');
    });
  }
}
