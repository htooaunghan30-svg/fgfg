import 'package:isar/isar.dart';

part 'badge_achievement.g.dart';

enum BadgeTier {
  bronze,
  silver,
  gold,
  platinum,
}

@Collection()
class BadgeAchievement {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String badgeId;
  
  late String name;
  late String description;
  late String iconPath;
  @enumerated
  late BadgeTier tier;
  
  late DateTime unlockedAt;
  late String unlockedFor; // exerciseId or 'general'
  late int progress; // Current progress towards badge
  late int requirement; // Requirement to unlock
  
  bool get isUnlocked => progress >= requirement;
  
  BadgeAchievement({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.tier,
    required this.unlockedAt,
    required this.unlockedFor,
    required this.progress,
    required this.requirement,
  });
}

