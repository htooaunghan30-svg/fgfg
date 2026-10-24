// lib/presentation/screens/progress_screen.dart
import 'package:flutter/material.dart';
//import 'package:charts_flutter/flutter.dart' as charts;
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/exercise_provider.dart';
import '../providers/user_provider.dart';
import '../services/trusted_progress_service.dart';
import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/badge_text_localizer.dart';
import '../../core/themes/color_scheme.dart';
import '../../data/models/badge_achievement.dart';
import '../../data/models/exercise_model.dart';

double _displayAccuracy(ExerciseLog log) {
  if (log.averageAccuracy > 0) {
    return log.averageAccuracy;
  }
  if (log.repDetails.isNotEmpty) {
    final sum = log.repDetails.fold(0.0, (total, rep) => total + rep.accuracy);
    return sum / log.repDetails.length;
  }
  return 0.0;
}

int _accuracyWeight(ExerciseLog log) {
  if (log.totalRepetitions > 0) {
    return log.totalRepetitions;
  }
  if (log.repDetails.isNotEmpty) {
    return log.repDetails.length;
  }
  if (log.averageAccuracy > 0) {
    return 1;
  }
  return 0;
}

final TrustedProgressService _trustedProgressService = TrustedProgressService();

List<ExerciseLog> _preferCompletedLogs(List<ExerciseLog> logs) {
  final filtered = logs
      .where((log) => log.totalRepetitions > 0 || log.repDetails.isNotEmpty)
      .toList();
  return filtered.isNotEmpty ? filtered : logs;
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('progress.title')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.t('progress.overview')),
            Tab(text: l10n.t('progress.exercises')),
            Tab(text: l10n.t('progress.badges')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _ExercisesTab(),
          _BadgesTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  Future<_WeeklySummaryData> _loadWeeklySummaryData(
    ExerciseProvider exerciseProvider,
  ) async {
    final logs = await exerciseProvider.watchExerciseLogs().first;
    final summary = await _trustedProgressService.buildWeeklySummary(logs);
    return _WeeklySummaryData(
      activities: summary.activities,
      currentStreak: summary.currentStreak,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekly Summary Card
          _buildWeeklySummaryCard(context, exerciseProvider, l10n),

          const SizedBox(height: 20),

          // Recent Workouts
          _buildRecentWorkoutsList(context, exerciseProvider, l10n),

          const SizedBox(height: 20),

          // Achievements
          _buildAchievementsSection(context, userProvider, l10n),
        ],
      ),
    );
  }

  Widget _buildWeeklySummaryCard(
    BuildContext context,
    ExerciseProvider provider,
    AppLocalizations l10n,
  ) {
    return FutureBuilder<_WeeklySummaryData>(
      future: _loadWeeklySummaryData(provider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text(l10n.t('progress.no_data'))),
            ),
          );
        }

        final weeklyActivities = snapshot.data!.activities;
        final totalReps = weeklyActivities.fold(
          0,
          (sum, activity) => sum + activity.totalRepetitions,
        );

        final totalWorkouts = weeklyActivities.fold(
          0,
          (sum, activity) => sum + activity.totalWorkouts,
        );

        final totalCalories = weeklyActivities.fold(
          0.0,
          (sum, activity) => sum + activity.estimatedCalories,
        );

        final streak = snapshot.data!.currentStreak;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('progress.weekly_summary'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      '$totalReps',
                      l10n.t('home.total_reps'),
                      Icons.repeat,
                    ),
                    _buildStatItem(
                      '$totalWorkouts',
                      l10n.t('home.workouts'),
                      Icons.fitness_center,
                    ),
                    _buildStatItem(
                      totalCalories.toStringAsFixed(0),
                      l10n.t('home.calories'),
                      Icons.local_fire_department,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Streak
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: streak > 0 ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.t(
                        'progress.streak_days',
                        params: {'count': '$streak'},
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: streak > 0 ? Colors.orange : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Progress chart for the week
                _buildWeeklyProgressChart(context, weeklyActivities, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgressChart(
    BuildContext context,
    List<UserActivity> activities,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final primaryColor =
        charts.ColorUtil.fromDartColor(theme.colorScheme.primary);
    final secondaryColor = charts.ColorUtil.fromDartColor(
        theme.colorScheme.secondary.withOpacity(0.5));

    // Create a beautiful vertical bar chart for daily reps
    final series = [
      charts.Series<UserActivity, String>(
        id: 'Reps',
        domainFn: (activity, _) => _getDayName(activity.date, l10n),
        measureFn: (activity, _) => activity.totalRepetitions,
        data: activities,
        colorFn: (_, __) => primaryColor,
        areaColorFn: (_, __) => secondaryColor,
        labelAccessorFn: (activity, _) => '${activity.totalRepetitions}',
      ),
    ];

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 16),
      child: charts.BarChart(
        series,
        animate: true,
        vertical: true, // Changed to vertical for better weekly overview
        animationDuration: const Duration(milliseconds: 800),
        barRendererDecorator: charts.BarLabelDecorator<String>(
          labelPosition: charts.BarLabelPosition.outside,
          labelPadding: 4,
          labelAnchor: charts.BarLabelAnchor.end,
          outsideLabelStyleSpec: charts.TextStyleSpec(
            fontSize: 10,
            color: charts.ColorUtil.fromDartColor(
                theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
        ),
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 11,
              color: charts.ColorUtil.fromDartColor(
                  theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(
                  theme.colorScheme.outline.withOpacity(0.1)),
            ),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 10,
              color: charts.ColorUtil.fromDartColor(
                  theme.colorScheme.onSurface.withOpacity(0.4)),
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(
                  theme.colorScheme.outline.withOpacity(0.1)),
              dashPattern: const [4, 4],
            ),
          ),
        ),
        defaultInteractions: true,
        behaviors: [
          charts.SelectNearest(),
          charts.DomainHighlighter(),
        ],
      ),
    );
  }

  Widget _buildRecentWorkoutsList(
    BuildContext context,
    ExerciseProvider provider,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('progress.recent_workouts'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // List of recent workouts
            StreamBuilder<List<ExerciseLog>>(
              stream: provider.watchExerciseLogs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return FutureBuilder<TrustedRecentWorkoutsSnapshot>(
                  future: _trustedProgressService
                      .buildRecentWorkouts(snapshot.data!),
                  builder: (context, trustedSnapshot) {
                    if (trustedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final recentWorkouts = trustedSnapshot.data?.workouts ?? [];
                    if (recentWorkouts.isEmpty) {
                      return Center(
                        child: Text(l10n.t('progress.no_workouts')),
                      );
                    }

                    final trustedNow =
                        trustedSnapshot.data?.trustedNow ?? DateTime.now();
                    return Column(
                      children: recentWorkouts
                          .map(
                            (workout) => _buildWorkoutListItem(
                              workout.log,
                              workout.trustedTimestamp,
                              trustedNow,
                              l10n,
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutListItem(
    ExerciseLog log,
    DateTime trustedTimestamp,
    DateTime trustedNow,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getExerciseColor(log.exerciseId),
        child: Text(
          log.exerciseId[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        _getExerciseName(log.exerciseId),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        l10n.t(
          'progress.workout_summary',
          params: {
            'reps': '${log.totalRepetitions}',
            'accuracy': (_displayAccuracy(log) * 100).toStringAsFixed(1),
          },
        ),
      ),
      trailing: Text(
        _formatTimeAgo(trustedTimestamp, trustedNow, l10n),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    UserProvider userProvider,
    AppLocalizations l10n,
  ) {
    final badges = userProvider.badges;
    final unlockedBadges = badges.where((b) => b.isUnlocked).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('progress.achievements'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              l10n.t(
                'progress.badges_unlocked',
                params: {
                  'unlocked': '$unlockedBadges',
                  'total': '${badges.length}',
                },
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Badge grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: badges.take(8).length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeWidget(badge);
              },
            ),

            if (badges.length > 8)
              TextButton(
                onPressed: () {
                  // Navigate to full achievements page
                },
                child: Text(l10n.t('progress.view_all_achievements')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeWidget(BadgeAchievement badge) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: badge.isUnlocked
                ? _getBadgeColor(badge.tier.name)
                : Colors.grey[300],
            shape: BoxShape.circle,
            border: Border.all(
              color: badge.isUnlocked ? Colors.amber : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: badge.isUnlocked
                ? const Icon(Icons.star, color: Colors.white)
                : const Icon(Icons.lock, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          badge.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: badge.isUnlocked ? FontWeight.bold : FontWeight.normal,
            color: badge.isUnlocked ? Colors.black : Colors.grey,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getBadgeColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return AppColorScheme.primary;
    }
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getDayName(DateTime date, AppLocalizations l10n) {
    const days = [
      'progress.day.sun',
      'progress.day.mon',
      'progress.day.tue',
      'progress.day.wed',
      'progress.day.thu',
      'progress.day.fri',
      'progress.day.sat',
    ];
    return l10n.t(days[date.weekday % 7]);
  }

  String _getExerciseName(String exerciseId) {
    switch (exerciseId) {
      case 'squat':
        return 'Squat';
      case 'pushup':
        return 'Push-up';
      case 'bicep_curl':
        return 'Bicep Curl';
      case 'lateral_raise':
        return 'Lateral Raise';
      case 'front_raise':
        return 'Front Raise';
      case 'shoulder_press':
        return 'Shoulder Press';
      case 'situp':
        return 'Sit-up';
      case 'leg_extension':
        return 'Leg Extension';
      default:
        return exerciseId;
    }
  }

  Color _getExerciseColor(String exerciseId) {
    switch (exerciseId) {
      case 'squat':
        return Colors.blue;
      case 'pushup':
        return Colors.red;
      case 'bicep_curl':
        return Colors.green;
      case 'lateral_raise':
        return Colors.deepOrange;
      case 'front_raise':
        return Colors.deepPurple;
      case 'shoulder_press':
        return Colors.orange;
      case 'situp':
        return Colors.purple;
      case 'leg_extension':
        return Colors.teal;
      default:
        return AppColorScheme.primary;
    }
  }

  String _formatTimeAgo(
    DateTime date,
    DateTime now,
    AppLocalizations l10n,
  ) {
    final difference = now.difference(date);

    if (difference.isNegative) {
      return l10n.t('progress.time.just_now');
    }

    if (difference.inMinutes < 1) {
      return l10n.t('progress.time.just_now');
    } else if (difference.inMinutes < 60) {
      return l10n.t(
        'progress.time.minutes_ago',
        params: {'value': '${difference.inMinutes}'},
      );
    } else if (difference.inHours < 24) {
      return l10n.t(
        'progress.time.hours_ago',
        params: {'value': '${difference.inHours}'},
      );
    } else if (difference.inDays < 7) {
      return l10n.t(
        'progress.time.days_ago',
        params: {'value': '${difference.inDays}'},
      );
    } else {
      return l10n.t(
        'progress.time.weeks_ago',
        params: {'value': '${(difference.inDays / 7).floor()}'},
      );
    }
  }
}

class _WeeklySummaryData {
  final List<UserActivity> activities;
  final int currentStreak;

  const _WeeklySummaryData({
    required this.activities,
    required this.currentStreak,
  });

  bool get isEmpty => activities.isEmpty;
}

class _ExercisesTab extends StatelessWidget {
  const _ExercisesTab();
  static const List<String> _supportedExerciseIds = <String>[
    'squat',
    'pushup',
    'situp',
    'bicep_curl',
    'shoulder_press',
    'lateral_raise',
    'front_raise',
    'leg_extension',
  ];

  static String _normalizeExerciseId(String rawId) {
    return rawId.toLowerCase().replaceAll('-', '_').trim();
  }

  List<ExerciseModel> _buildProgressExerciseList(List<ExerciseModel> all) {
    final grouped = <String, List<ExerciseModel>>{};
    for (final exercise in all) {
      final normalizedId = _normalizeExerciseId(exercise.exerciseId);
      if (!_supportedExerciseIds.contains(normalizedId)) {
        continue;
      }
      grouped.putIfAbsent(normalizedId, () => <ExerciseModel>[]).add(exercise);
    }

    final resolved = <ExerciseModel>[];
    for (final id in _supportedExerciseIds) {
      final candidates = grouped[id];
      if (candidates == null || candidates.isEmpty) {
        continue;
      }

      ExerciseModel best = candidates.first;
      for (final candidate in candidates.skip(1)) {
        final bestExact = _normalizeExerciseId(best.exerciseId) == id;
        final candidateExact = _normalizeExerciseId(candidate.exerciseId) == id;
        if (candidateExact && !bestExact) {
          best = candidate;
          continue;
        }
        if (candidate.totalReps > best.totalReps) {
          best = candidate;
          continue;
        }
        if (candidate.totalReps == best.totalReps &&
            candidate.lastPerformed.isAfter(best.lastPerformed)) {
          best = candidate;
        }
      }

      resolved.add(best);
    }

    return resolved;
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final l10n = context.l10n;
    final exercises = _buildProgressExerciseList(exerciseProvider.exercises);

    return ListView.builder(
      itemCount: exercises.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildExercisesIntro(context);
        }
        final exercise = exercises[index - 1];
        return _buildExerciseProgressCard(
          context,
          exercise,
          exerciseProvider,
          l10n,
        );
      },
    );
  }

  Widget _buildExercisesIntro(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.t('progress.read_exercise_analytics_title'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _GuideLine(
              icon: Icons.bolt_rounded,
              text: l10n.t('progress.read_exercise_analytics_line1'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
            const SizedBox(height: 6),
            _GuideLine(
              icon: Icons.emoji_events_outlined,
              text: l10n.t('progress.read_exercise_analytics_line2'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
            const SizedBox(height: 6),
            _GuideLine(
              icon: Icons.bar_chart_rounded,
              text: l10n.t('progress.read_exercise_analytics_line3'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
            const SizedBox(height: 6),
            _GuideLine(
              icon: Icons.tag_rounded,
              text: l10n.t('progress.read_exercise_analytics_line4'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseProgressCard(
    BuildContext context,
    ExerciseModel exercise,
    ExerciseProvider provider,
    AppLocalizations l10n,
  ) {
    final logs = [...provider.getExerciseLogs(exercise.exerciseId)]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final displayLogs = _preferCompletedLogs(logs);
    final latestLog = displayLogs.isNotEmpty ? displayLogs.last : null;
    final previousLog =
        displayLogs.length > 1 ? displayLogs[displayLogs.length - 2] : null;
    final latestAccuracy =
        (latestLog == null ? 0.0 : _displayAccuracy(latestLog)) * 100;
    final bestAccuracy = displayLogs.isEmpty
        ? 0.0
        : displayLogs
            .map((log) => _displayAccuracy(log) * 100)
            .reduce((a, b) => a > b ? a : b);
    final totalAccuracyWeight =
        displayLogs.fold(0, (sum, log) => sum + _accuracyWeight(log));
    final weightedAccuracySum = displayLogs.fold(
      0.0,
      (sum, log) => sum + (_displayAccuracy(log) * _accuracyWeight(log)),
    );
    final avgAccuracy = totalAccuracyWeight > 0
        ? (weightedAccuracySum / totalAccuracyWeight) * 100
        : 0.0;
    final trendDelta = previousLog == null
        ? null
        : latestAccuracy - (_displayAccuracy(previousLog) * 100);
    final chartLogs = displayLogs.length <= 6
        ? displayLogs
        : displayLogs.sublist(displayLogs.length - 6);

    final exerciseColor = _getExerciseColor(exercise.exerciseId);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: exerciseColor,
                  child: Text(
                    exercise.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: exerciseColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${logs.length} ${l10n.t('progress.sessions')}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: exerciseColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightTile(
                    icon: Icons.repeat_rounded,
                    value: '${exercise.totalReps}',
                    label: l10n.t('progress.total_reps_all_time'),
                    color: exerciseColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInsightTile(
                    icon: Icons.track_changes_rounded,
                    value: '${avgAccuracy.toStringAsFixed(1)}%',
                    label: l10n.t('progress.avg_accuracy_all_sessions'),
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInsightTile(
                    icon: Icons.flash_on_rounded,
                    value: latestLog == null
                        ? '--'
                        : '${latestAccuracy.toStringAsFixed(1)}%',
                    label: l10n.t('progress.latest_accuracy'),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInsightTile(
                    icon: Icons.emoji_events_rounded,
                    value: logs.isEmpty
                        ? '--'
                        : '${bestAccuracy.toStringAsFixed(1)}%',
                    label: l10n.t('progress.best_accuracy'),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (trendDelta != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: trendDelta >= 0
                      ? Colors.green.withOpacity(0.10)
                      : Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendDelta >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: trendDelta >= 0 ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.t(
                          'progress.trend_vs_previous_session',
                          params: {
                            'sign': trendDelta >= 0 ? '+' : '',
                            'delta': trendDelta.toStringAsFixed(1),
                          },
                        ),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: trendDelta >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (chartLogs.isNotEmpty)
              _buildSimpleAccuracyChart(
                context,
                chartLogs,
                exerciseColor,
                l10n,
              )
            else
              Text(
                l10n.t('progress.no_sessions'),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAccuracyChart(
    BuildContext context,
    List<ExerciseLog> logs,
    Color color,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('progress.last_sessions_accuracy_title'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: logs.asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                final accuracy =
                    (_displayAccuracy(log) * 100).clamp(0.0, 100.0);
                final barHeight = 26 + (accuracy / 100) * 76;
                final sessionTag = 'S${index + 1}';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${accuracy.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 24,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${log.totalRepetitions}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.t('progress.reps_short'),
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.65),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sessionTag,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.t('progress.chart_accuracy_trend_legend'),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getExerciseColor(String exerciseId) {
    switch (exerciseId.toLowerCase()) {
      case 'squat':
        return const Color(0xFF2563EB);
      case 'pushup':
        return const Color(0xFF16A34A);
      case 'situp':
        return const Color(0xFFD97706);
      case 'bicep_curl':
        return const Color(0xFF7C3AED);
      case 'lateral_raise':
        return const Color(0xFFEA580C);
      case 'front_raise':
        return const Color(0xFF8B5CF6);
      case 'shoulder_press':
        return const Color(0xFFDC2626);
      case 'leg_extension':
        return const Color(0xFF0891B2);
      default:
        return Colors.teal;
    }
  }
}

class _BadgesTab extends StatefulWidget {
  const _BadgesTab();

  @override
  State<_BadgesTab> createState() => _BadgesTabState();
}

class _BadgesTabState extends State<_BadgesTab> {
  final Set<String> _autoExpandedBadgeIds = <String>{};
  final Set<String> _glowBadgeIds = <String>{};
  bool _isPreparingCelebration = false;

  Future<void> _prepareCelebrationForToday(
      List<BadgeAchievement> badges) async {
    if (_isPreparingCelebration || badges.isEmpty) {
      return;
    }

    _isPreparingCelebration = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final key =
          'celebrated_badges_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
      final seen = prefs.getStringList(key) ?? <String>[];

      final newlyUnlockedToday = badges
          .where(
            (badge) =>
                badge.isUnlocked &&
                _isSameDay(badge.unlockedAt, now) &&
                !seen.contains(badge.badgeId),
          )
          .map((badge) => badge.badgeId)
          .toSet();

      if (newlyUnlockedToday.isEmpty) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _autoExpandedBadgeIds.addAll(newlyUnlockedToday);
        _glowBadgeIds.addAll(newlyUnlockedToday);
      });

      await prefs.setStringList(
        key,
        <String>{...seen, ...newlyUnlockedToday}.toList(),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (!mounted) {
        return;
      }
      setState(() {
        _glowBadgeIds.removeAll(newlyUnlockedToday);
      });
    } finally {
      _isPreparingCelebration = false;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userProvider = Provider.of<UserProvider>(context);
    final badges = [...userProvider.badges]..sort(
        (a, b) => _tierRank(a.tier).compareTo(_tierRank(b.tier)),
      );

    if (badges.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.workspace_premium_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.t('badges.empty'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    final unlockedCount = badges.where((badge) => badge.isUnlocked).length;
    final completion = unlockedCount / badges.length;
    final inProgress = badges.where((badge) => !badge.isUnlocked).toList()
      ..sort((a, b) => _completionRatio(b).compareTo(_completionRatio(a)));
    final nextBadge = inProgress.isNotEmpty ? inProgress.first : null;
    final highestUnlockedTier = _getHighestUnlockedTier(badges);
    _prepareCelebrationForToday(badges);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildStatusHero(
          context: context,
          unlockedCount: unlockedCount,
          totalCount: badges.length,
          completion: completion,
          currentTier: highestUnlockedTier,
          nextBadge: nextBadge,
        ),
        const SizedBox(height: 16),
        _buildBadgeSystemGuide(context),
        const SizedBox(height: 16),
        Text(
          l10n.t('badges.collection'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        ...badges.map(
          (badge) => _buildDetailedBadgeCard(
            context,
            badge,
            isAutoExpanded: _autoExpandedBadgeIds.contains(badge.badgeId),
            isGlowing: _glowBadgeIds.contains(badge.badgeId),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHero({
    required BuildContext context,
    required int unlockedCount,
    required int totalCount,
    required double completion,
    required String currentTier,
    required BadgeAchievement? nextBadge,
  }) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF224B86), Color(0xFF162E54)]
              : const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x332563EB) : const Color(0x442563EB),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                l10n.t('badges.current_status'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.t(
              'badges.unlocked_count',
              params: {'unlocked': '$unlockedCount', 'total': '$totalCount'},
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 9,
              backgroundColor: const Color(0x55FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.t('badges.tier', params: {'tier': currentTier}),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (nextBadge != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.t(
                'badges.next_target',
                params: {
                  'name': BadgeTextLocalizer.localizedName(l10n, nextBadge),
                  'progress': '${nextBadge.progress}',
                  'requirement': '${nextBadge.requirement}',
                  'percent': (completion * 100).toStringAsFixed(0),
                },
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeSystemGuide(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('badges.how_it_works'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            _GuideLine(
              icon: Icons.calendar_today_rounded,
              text: l10n.t('badges.guide_1'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
            const SizedBox(height: 6),
            _GuideLine(
              icon: Icons.flag_circle_rounded,
              text: l10n.t('badges.guide_2'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
            const SizedBox(height: 6),
            _GuideLine(
              icon: Icons.insights_rounded,
              text: l10n.t('badges.guide_3'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
            const SizedBox(height: 6),
            _GuideLine(
              icon: Icons.fitness_center_rounded,
              text: l10n.t('badges.guide_4'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
            const SizedBox(height: 6),
            _GuideLine(
              icon: Icons.storage_rounded,
              text: l10n.t('badges.guide_5'),
              textColor: colors.onSurface.withOpacity(0.9),
              iconColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBadgeCard(
    BuildContext context,
    BadgeAchievement badge, {
    required bool isAutoExpanded,
    required bool isGlowing,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPosterSaved = userProvider.isBadgePosterSaved(badge.badgeId);
    final isPosterSaveFailed =
        userProvider.isBadgePosterSaveFailed(badge.badgeId);
    final ratio = _completionRatio(badge);
    final tierColor = _getTierColor(badge.tier.name);
    final details = BadgeTextLocalizer.localizedPlanDetails(l10n, badge);
    final motivation = _buildMotivationLine(l10n, badge);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isGlowing)
            BoxShadow(
              color: tierColor.withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isGlowing
                ? tierColor.withOpacity(0.9)
                : badge.isUnlocked
                    ? tierColor.withOpacity(0.45)
                    : colors.outline.withOpacity(0.28),
            width: isGlowing ? 1.8 : 1,
          ),
        ),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey('badge_${badge.badgeId}_$isAutoExpanded'),
            initiallyExpanded: isAutoExpanded,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            iconColor: colors.onSurface.withOpacity(0.85),
            collapsedIconColor: colors.onSurface.withOpacity(0.75),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: badge.isUnlocked
                        ? tierColor
                        : colors.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: badge.isUnlocked
                        ? TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 550),
                            tween: Tween<double>(begin: 0.86, end: 1.0),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                  scale: value, child: child);
                            },
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.lock_outline_rounded,
                            color: colors.onSurface.withOpacity(0.65),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BadgeTextLocalizer.localizedName(l10n, badge),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        BadgeTextLocalizer.localizedNarrative(l10n, badge),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.onSurface.withOpacity(0.92),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTierPill(
                        context,
                        BadgeTextLocalizer.tierLabel(l10n, badge),
                        tierColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: colors.onSurface.withOpacity(0.14),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        badge.isUnlocked ? tierColor : const Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${badge.progress}/${badge.requirement}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: colors.onSurface.withOpacity(0.92),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        badge.isUnlocked
                            ? l10n.t(
                                'badges.unlocked_on',
                                params: {'date': _formatDate(badge.unlockedAt)},
                              )
                            : l10n.t('badges.tap_full_plan'),
                        style: TextStyle(
                          fontSize: 12,
                          color: badge.isUnlocked
                              ? Colors.green.shade700
                              : colors.onSurface.withOpacity(0.72),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            children: [
              if (isGlowing)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: tierColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: tierColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.t('badges.new_unlock_today'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (badge.isUnlocked)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tierColor.withOpacity(0.2),
                        tierColor.withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 16,
                        color: tierColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.t('badges.unlocked_banner'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface.withOpacity(0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (badge.isUnlocked && isPosterSaved)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.t(
                            'badges.poster_saved_note',
                            params: {
                              'album': userProvider.badgePosterAlbumName
                            },
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface.withOpacity(0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (badge.isUnlocked && !isPosterSaved && isPosterSaveFailed)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.error.withOpacity(0.30)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: colors.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.t('badges.poster_save_failed_note'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface.withOpacity(0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildBadgeDayProgress(
                context: context,
                badge: badge,
                accentColor:
                    badge.isUnlocked ? tierColor : const Color(0xFF1A73E8),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.045),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: details
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Icon(
                                  Icons.fiber_manual_record_rounded,
                                  size: 8,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  line,
                                  style: TextStyle(
                                    fontSize: 12.2,
                                    height: 1.35,
                                    color: colors.onSurface.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                motivation,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeDayProgress({
    required BuildContext context,
    required BadgeAchievement badge,
    required Color accentColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final total = badge.requirement <= 0 ? 1 : badge.requirement;
    final completed = badge.progress.clamp(0, total);
    final ratio = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final isPrep = badge.badgeId == 'prep_phase_15_v2';
    final isMonthly = badge.badgeId == 'month_1_bronze' ||
        badge.badgeId == 'month_2_silver' ||
        badge.badgeId == 'month_3_gold';

    final chips = _buildDayProgressChips(
      totalActiveDays: total,
      completedActiveDays: completed,
      isPrep: isPrep,
      isMonthly: isMonthly,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "$completed/$total ${l10n.t('leaderboard.days')}",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface.withOpacity(0.92),
                ),
              ),
              const Spacer(),
              Text(
                '${(ratio * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: colors.onSurface.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips.map((chip) {
              final bg = chip.done
                  ? (chip.isRest ? accentColor.withOpacity(0.65) : accentColor)
                  : (chip.isRest
                      ? colors.onSurface.withOpacity(0.05)
                      : Colors.transparent);

              final borderColor = chip.done
                  ? Colors.transparent
                  : colors.outline.withOpacity(chip.isRest ? 0.18 : 0.28);

              final fg = chip.done
                  ? Colors.white
                  : colors.onSurface.withOpacity(chip.isRest ? 0.55 : 0.78);

              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: chip.isRest
                      ? Icon(
                          Icons.bedtime_outlined,
                          size: 13,
                          color: fg,
                        )
                      : Text(
                          chip.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: fg,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<_BadgeDayChip> _buildDayProgressChips({
    required int totalActiveDays,
    required int completedActiveDays,
    required bool isPrep,
    required bool isMonthly,
  }) {
    if (isPrep) {
      return List.generate(totalActiveDays, (index) {
        final day = index + 1;
        final isRest = day == 6 || day == 7 || day == 13 || day == 14;
        final done = day <= completedActiveDays;
        return _BadgeDayChip(
          label: '$day',
          done: done,
          isRest: isRest,
        );
      });
    }

    if (!isMonthly) {
      return List.generate(totalActiveDays, (index) {
        final day = index + 1;
        return _BadgeDayChip(
          label: '$day',
          done: day <= completedActiveDays,
          isRest: false,
        );
      });
    }

    // Month badges use a 5 active + 2 rest rhythm.
    final chips = <_BadgeDayChip>[];
    var activeDay = 0;
    var cycleDay = 0;
    while (activeDay < totalActiveDays) {
      cycleDay += 1;
      final dayInCycle = ((cycleDay - 1) % 7) + 1;
      final isRest = dayInCycle > 5;
      if (isRest) {
        final cycleNumber = ((cycleDay - 1) ~/ 7) + 1;
        final restDone = completedActiveDays >= cycleNumber * 5;
        chips.add(
          _BadgeDayChip(
            label: '$cycleDay',
            done: restDone,
            isRest: true,
          ),
        );
        continue;
      }

      activeDay += 1;
      chips.add(
        _BadgeDayChip(
          label: '$activeDay',
          done: activeDay <= completedActiveDays,
          isRest: false,
        ),
      );
    }
    return chips;
  }

  Widget _buildTierPill(BuildContext context, String tierName, Color color) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        tierName.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          color: colors.brightness == Brightness.dark ? Colors.white : color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _buildMotivationLine(AppLocalizations l10n, BadgeAchievement badge) {
    if (badge.isUnlocked) {
      return l10n.t('badges.motivation_unlocked');
    }

    final remaining =
        (badge.requirement - badge.progress).clamp(0, badge.requirement);
    if (remaining <= 3) {
      return l10n.t(
        'badges.motivation_almost',
        params: {'remaining': '$remaining'},
      );
    }

    return l10n.t('badges.motivation_keep');
  }

  String _getHighestUnlockedTier(List<BadgeAchievement> badges) {
    final l10n = context.l10n;
    final unlocked = badges.where((badge) => badge.isUnlocked).toList();
    if (unlocked.isEmpty) {
      return l10n.t('badges.no_tier');
    }

    unlocked.sort((a, b) => _tierRank(b.tier).compareTo(_tierRank(a.tier)));
    return BadgeTextLocalizer.tierLabel(l10n, unlocked.first);
  }

  int _tierRank(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze:
        return 0;
      case BadgeTier.silver:
        return 1;
      case BadgeTier.gold:
        return 2;
      case BadgeTier.platinum:
        return 3;
    }
  }

  double _completionRatio(BadgeAchievement badge) {
    if (badge.requirement <= 0) {
      return 0;
    }
    return (badge.progress / badge.requirement).clamp(0.0, 1.0).toDouble();
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return AppColorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _GuideLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textColor;
  final Color iconColor;

  const _GuideLine({
    required this.icon,
    required this.text,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: textColor,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeDayChip {
  final String label;
  final bool done;
  final bool isRest;

  const _BadgeDayChip({
    required this.label,
    required this.done,
    required this.isRest,
  });
}
