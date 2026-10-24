// lib/features/gamification/leaderboard_engine.dart
import 'dart:math';
import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';
import 'package:flutter/material.dart';

class LeaderboardEngine {
  // Simulate global leaderboard data for local-first app
  static List<LeaderboardEntry> generateSimulatedLeaderboard({
    int count = 50,
    DateTimeRange? dateRange,
  }) {
    final entries = <LeaderboardEntry>[];
    final now = DateTime.now();
    
    // Add user's entry first
    final userEntry = _createUserEntry();
    entries.add(userEntry);
    
    // Generate simulated competitors
    for (int i = 1; i < count; i++) {
      entries.add(_createSimulatedEntry(i, now));
    }
    
    // Sort by score
    entries.sort((a, b) => b.score.compareTo(a.score));
    
    // Update ranks
    for (int i = 0; i < entries.length; i++) {
      entries[i] = entries[i].copyWith(rank: i + 1);
    }
    
    return entries;
  }
  
  static LeaderboardEntry _createUserEntry() {
    // This would use actual user data
    return LeaderboardEntry(
      id: 'user',
      name: 'You',
      score: _calculateUserScore(),
      rank: 1,
      avatarUrl: null,
      stats: _getUserStats(),
      isCurrentUser: true,
    );
  }
  
  static LeaderboardEntry _createSimulatedEntry(int index, DateTime now) {
    final names = [
      'Fitness Pro', 'Gym Rat', 'Workout Warrior', 'Exercise Expert',
      'Health Hero', 'Strength Master', 'Endurance King', 'Flexibility Guru',
      'Balance Boss', 'Power Pro', 'Speed Demon', 'Agility Ace',
      'Cardio Champion', 'Muscle Machine', 'Wellness Wizard', 'Vitality Victor',
      'Energy Emperor', 'Stamina Sultan', 'Powerhouse', 'Titan',
    ];
    
    final name = names[index % names.length];
    final baseScore = 500 + Random().nextInt(1000);
    final activityScore = Random().nextInt(500);
    const consistencyBonus = 200;
    
    return LeaderboardEntry(
      id: 'simulated_$index',
      name: '$name ${index ~/ names.length + 1}',
      score: baseScore + activityScore + consistencyBonus,
      rank: index + 1,
      avatarUrl: null,
      stats: {
        'totalWorkouts': 10 + Random().nextInt(50),
        'streak': Random().nextInt(30),
        'accuracy': 70 + Random().nextInt(30),
        'favoriteExercise': _getRandomExercise(),
      },
      isCurrentUser: false,
    );
  }
  
  static int _calculateUserScore() {
    // Calculate user score based on various factors
    // This would use actual user data
    return 1250; // Example score
  }
  
  static Map<String, dynamic> _getUserStats() {
    // Get actual user stats
    return {
      'totalWorkouts': 45,
      'streak': 7,
      'accuracy': 85,
      'favoriteExercise': 'Squat',
    };
  }
  
  static String _getRandomExercise() {
    final exercises = [
      'Squat', 'Push-up', 'Bicep Curl', 'Shoulder Press',
      'Sit-up', 'Leg Extension',
    ];
    return exercises[Random().nextInt(exercises.length)];
  }
  
  static List<LeaderboardEntry> filterByDateRange(
    List<LeaderboardEntry> entries,
    DateTimeRange range,
  ) {
    // In a real implementation, this would filter entries based on activity date
    // For simulated data, return all entries
    return entries;
  }
  
  static List<LeaderboardEntry> getTopPerformers(
    List<LeaderboardEntry> entries, {
    int count = 10,
    String? exerciseId,
  }) {
    var filteredEntries = entries;
    
    if (exerciseId != null) {
      // Filter by exercise (would require exercise-specific scores)
      filteredEntries = entries.where((entry) {
        return entry.stats['favoriteExercise'] == exerciseId;
      }).toList();
    }
    
    return filteredEntries.take(count).toList();
  }
  
  static Map<String, dynamic> analyzeCompetition(List<LeaderboardEntry> entries) {
    final userEntry = entries.firstWhere((entry) => entry.isCurrentUser);
    final topEntry = entries.first;
    
    final scoreDifference = topEntry.score - userEntry.score;
    final rankDifference = userEntry.rank - 1; // How far from top
    
    String nextMilestone = '';
    if (scoreDifference <= 100) {
      nextMilestone = 'Almost there! ${scoreDifference} points to #1';
    } else if (scoreDifference <= 500) {
      nextMilestone = '${scoreDifference} points to reach top ${rankDifference ~/ 10 + 1}';
    } else {
      nextMilestone = 'Keep going! Focus on consistency';
    }
    
    return {
      'userRank': userEntry.rank,
      'topScore': topEntry.score,
      'scoreDifference': scoreDifference,
      'nextMilestone': nextMilestone,
      'totalCompetitors': entries.length,
      'percentile': ((entries.length - userEntry.rank) / entries.length * 100).toInt(),
    };
  }
}

class LeaderboardEntry {
  final String id;
  final String name;
  final int score;
  final int rank;
  final String? avatarUrl;
  final Map<String, dynamic> stats;
  final bool isCurrentUser;
  
  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.score,
    required this.rank,
    this.avatarUrl,
    required this.stats,
    required this.isCurrentUser,
  });
  
  LeaderboardEntry copyWith({
    String? id,
    String? name,
    int? score,
    int? rank,
    String? avatarUrl,
    Map<String, dynamic>? stats,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stats: stats ?? this.stats,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'rank': rank,
      'avatarUrl': avatarUrl,
      'stats': stats,
      'isCurrentUser': isCurrentUser,
    };
  }
  
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'],
      name: json['name'],
      score: json['score'],
      rank: json['rank'],
      avatarUrl: json['avatarUrl'],
      stats: Map<String, dynamic>.from(json['stats']),
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}

class LeaderboardScreenData {
  final List<LeaderboardEntry> entries;
  final Map<String, dynamic> analysis;
  final DateTimeRange dateRange;
  
  LeaderboardScreenData({
    required this.entries,
    required this.analysis,
    required this.dateRange,
  });
  
  LeaderboardEntry get userEntry {
    return entries.firstWhere((entry) => entry.isCurrentUser);
  }
  
  List<LeaderboardEntry> get topThree {
    return entries.take(3).toList();
  }
  
  List<LeaderboardEntry> get nearbyCompetitors {
    final userIndex = entries.indexWhere((entry) => entry.isCurrentUser);
    final start = max(0, userIndex - 2);
    final end = min(entries.length, userIndex + 3);
    
    return entries.sublist(start, end);
  }
}
