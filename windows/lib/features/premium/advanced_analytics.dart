// lib/features/premium/advanced_analytics.dart
import 'dart:math';
import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart' as charts;
//import 'package:charts_flutter/flutter.dart' as charts;
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';

class AdvancedAnalytics {
  static Map<String, dynamic> analyzeWorkoutPatterns(List<ExerciseLog> logs) {
    if (logs.isEmpty) {
      return {
        'consistency': 0.0,
        'improvementRate': 0.0,
        'peakPerformance': 0.0,
        'fatigueFactor': 0.0,
      };
    }

    // Sort logs by date
    logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate consistency (standard deviation of accuracy)
    final accuracies = logs.map((log) => log.averageAccuracy).toList();
    final consistency = _calculateConsistency(accuracies);

    // Calculate improvement rate
    final improvementRate = _calculateImprovementRate(accuracies);

    // Calculate peak performance
    final peakPerformance = _calculatePeakPerformance(logs);

    // Calculate fatigue factor (performance decline in longer sessions)
    final fatigueFactor = _calculateFatigueFactor(logs);

    // Calculate workout frequency pattern
    final frequencyPattern = _analyzeFrequencyPattern(logs);

    // Calculate best time of day
    final bestTimeOfDay = _analyzeBestTimeOfDay(logs);

    return {
      'consistency': consistency,
      'improvementRate': improvementRate,
      'peakPerformance': peakPerformance,
      'fatigueFactor': fatigueFactor,
      'frequencyPattern': frequencyPattern,
      'bestTimeOfDay': bestTimeOfDay,
      'totalSessions': logs.length,
      'averageSessionDuration': _calculateAverageDuration(logs),
      'mostFrequentExercise': _findMostFrequentExercise(logs),
      'personalRecords': _findPersonalRecords(logs),
    };
  }

  static double _calculateConsistency(List<double> values) {
    if (values.length < 2) return 1.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
            values.length;

    final stdDev = sqrt(variance);
    final coefficientOfVariation = stdDev / mean;

    // Convert to consistency score (1 = perfect consistency)
    return (1.0 - coefficientOfVariation).clamp(0.0, 1.0);
  }

  static double _calculateImprovementRate(List<double> accuracies) {
    if (accuracies.length < 2) return 0.0;

    // Use linear regression to calculate improvement rate
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < accuracies.length; i++) {
      sumX += i.toDouble();
      sumY += accuracies[i];
      sumXY += i * accuracies[i];
      sumX2 += i * i;
    }

    final n = accuracies.length.toDouble();
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    return slope;
  }

  static double _calculatePeakPerformance(List<ExerciseLog> logs) {
    if (logs.isEmpty) return 0.0;

    // Find the best 10% of sessions
    final sortedLogs = List<ExerciseLog>.from(logs)
      ..sort((a, b) => b.averageAccuracy.compareTo(a.averageAccuracy));

    final topCount = max(1, (logs.length * 0.1).ceil());
    final topLogs = sortedLogs.take(topCount).toList();

    return topLogs.map((log) => log.averageAccuracy).reduce((a, b) => a + b) /
        topCount;
  }

  static double _calculateFatigueFactor(List<ExerciseLog> logs) {
    if (logs.length < 2) return 0.0;

    double totalFatigue = 0.0;
    int count = 0;

    for (int i = 1; i < logs.length; i++) {
      final previousLog = logs[i - 1];
      final currentLog = logs[i];

      final timeDifference =
          currentLog.timestamp.difference(previousLog.timestamp);

      // Only consider sessions within 48 hours
      if (timeDifference.inHours <= 48) {
        final performanceDrop =
            previousLog.averageAccuracy - currentLog.averageAccuracy;
        if (performanceDrop > 0) {
          totalFatigue += performanceDrop;
          count++;
        }
      }
    }

    return count > 0 ? totalFatigue / count : 0.0;
  }

  static Map<String, dynamic> _analyzeFrequencyPattern(List<ExerciseLog> logs) {
    final Map<int, int> dayCount = {}; // 0 = Sunday, 6 = Saturday
    final Map<int, int> hourCount = {}; // 0-23

    for (final log in logs) {
      final day = log.timestamp.weekday % 7;
      final hour = log.timestamp.hour;

      dayCount[day] = (dayCount[day] ?? 0) + 1;
      hourCount[hour] = (hourCount[hour] ?? 0) + 1;
    }

    // Find most active day and hour
    final mostActiveDay =
        dayCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    final mostActiveHour =
        hourCount.entries.reduce((a, b) => a.value > b.value ? a : b);

    return {
      'mostActiveDay': _getDayName(mostActiveDay.key),
      'mostActiveHour': mostActiveHour.key,
      'dayDistribution': dayCount,
      'hourDistribution': hourCount,
    };
  }

  static String _analyzeBestTimeOfDay(List<ExerciseLog> logs) {
    if (logs.isEmpty) return 'Not enough data';

    // Group by time of day
    final Map<String, List<double>> timeGroups = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
      'Night': [],
    };

    for (final log in logs) {
      final hour = log.timestamp.hour;
      String timeGroup;

      if (hour >= 5 && hour < 12) {
        timeGroup = 'Morning';
      } else if (hour >= 12 && hour < 17) {
        timeGroup = 'Afternoon';
      } else if (hour >= 17 && hour < 22) {
        timeGroup = 'Evening';
      } else {
        timeGroup = 'Night';
      }

      timeGroups[timeGroup]!.add(log.averageAccuracy);
    }

    // Find time group with highest average accuracy
    double bestAverage = 0.0;
    String bestTime = 'Not enough data';

    for (final entry in timeGroups.entries) {
      if (entry.value.isNotEmpty) {
        final average =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
        if (average > bestAverage) {
          bestAverage = average;
          bestTime = entry.key;
        }
      }
    }

    return bestTime;
  }

  static Duration _calculateAverageDuration(List<ExerciseLog> logs) {
    if (logs.isEmpty) return Duration.zero;

    final totalSeconds = logs.fold(
      0,
      (sum, log) => sum + log.sessionDuration,
    );

    return Duration(seconds: totalSeconds ~/ logs.length);
  }

  static String _findMostFrequentExercise(List<ExerciseLog> logs) {
    if (logs.isEmpty) return 'No data';

    final exerciseCount = <String, int>{};

    for (final log in logs) {
      exerciseCount[log.exerciseId] = (exerciseCount[log.exerciseId] ?? 0) + 1;
    }

    final mostFrequent =
        exerciseCount.entries.reduce((a, b) => a.value > b.value ? a : b);

    return mostFrequent.key;
  }

  static Map<String, dynamic> _findPersonalRecords(List<ExerciseLog> logs) {
    if (logs.isEmpty) return {};

    final records = <String, Map<String, dynamic>>{};

    for (final log in logs) {
      if (!records.containsKey(log.exerciseId) ||
          log.averageAccuracy >
              (records[log.exerciseId]!['accuracy'] as double)) {
        records[log.exerciseId] = {
          'accuracy': log.averageAccuracy,
          'reps': log.totalRepetitions,
          'date': log.timestamp,
        };
      }
    }

    return records;
  }

  static String _getDayName(int dayIndex) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[dayIndex];
  }
}

class AnalyticsChart extends StatelessWidget {
  final List<ExerciseLog> logs;
  final String chartType;

  const AnalyticsChart({
    super.key,
    required this.logs,
    this.chartType = 'accuracy',
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    // Sort logs by date
    logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Prepare data based on chart type
    final series = _prepareChartSeries(logs, chartType);

    return SizedBox(
      height: 300,
      child: charts.TimeSeriesChart(
        series,
        animate: true,
        defaultRenderer: charts.LineRendererConfig(includePoints: true),
        behaviors: [
          charts.SeriesLegend(),
          charts.ChartTitle('Date'),
          charts.ChartTitle(
            chartType == 'accuracy' ? 'Accuracy (%)' : 'Repetitions',
            behaviorPosition: charts.BehaviorPosition.start,
          ),
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
        ],
      ),
    );
  }

  List<charts.Series<TimeSeriesData, DateTime>> _prepareChartSeries(
    List<ExerciseLog> logs,
    String type,
  ) {
    final data = logs.map((log) {
      return TimeSeriesData(
        date: log.timestamp,
        value: type == 'accuracy'
            ? log.averageAccuracy * 100
            : log.totalRepetitions.toDouble(),
        exerciseId: log.exerciseId,
      );
    }).toList();

    return [
      charts.Series<TimeSeriesData, DateTime>(
        id: type == 'accuracy' ? 'Accuracy' : 'Repetitions',
        domainFn: (data, _) => data.date,
        measureFn: (data, _) => data.value,
        data: data,
        colorFn: (data, _) => _getExerciseColor(data.exerciseId),
      ),
    ];
  }

  charts.Color _getExerciseColor(String exerciseId) {
    final colorMap = {
      'squat': charts.MaterialPalette.blue.shadeDefault,
      'pushup': charts.MaterialPalette.red.shadeDefault,
      'bicep_curl': charts.MaterialPalette.green.shadeDefault,
      'shoulder_press': charts.MaterialPalette.deepOrange.shadeDefault,
      'situp': charts.MaterialPalette.purple.shadeDefault,
      'leg_extension': charts.MaterialPalette.teal.shadeDefault,
    };

    return colorMap[exerciseId] ?? charts.MaterialPalette.gray.shadeDefault;
  }
}

class TimeSeriesData {
  final DateTime date;
  final double value;
  final String exerciseId;

  TimeSeriesData({
    required this.date,
    required this.value,
    required this.exerciseId,
  });
}

class AnalyticsScreen extends StatelessWidget {
  final List<ExerciseLog> logs;

  const AnalyticsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final analytics = AdvancedAnalytics.analyzeWorkoutPatterns(logs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Key Metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem(
                          '${((analytics['consistency'] as double) * 100).toStringAsFixed(1)}%',
                          'Consistency',
                          Icons.timeline,
                        ),
                        _buildMetricItem(
                          '${((analytics['improvementRate'] as double) * 100).toStringAsFixed(1)}%',
                          'Improvement',
                          Icons.trending_up,
                        ),
                        _buildMetricItem(
                          '${((analytics['peakPerformance'] as double) * 100).toStringAsFixed(1)}%',
                          'Peak',
                          Icons.rocket_launch,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Charts
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Trends',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnalyticsChart(logs: logs, chartType: 'accuracy'),
                    const SizedBox(height: 20),
                    AnalyticsChart(logs: logs, chartType: 'reps'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Insights
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insights & Recommendations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInsightItem(
                      'Best Time to Workout',
                      'Your performance is best during ${analytics['bestTimeOfDay']}',
                      Icons.access_time,
                    ),
                    _buildInsightItem(
                      'Most Consistent Exercise',
                      'You perform ${analytics['mostFrequentExercise']} most regularly',
                      Icons.repeat,
                    ),
                    if (analytics['fatigueFactor'] as double > 0.1)
                      _buildInsightItem(
                        'Rest Recommendation',
                        'Consider more rest between intense sessions',
                        Icons.bedtime,
                      ),
                    if (analytics['consistency'] as double < 0.7)
                      _buildInsightItem(
                        'Form Focus',
                        'Work on maintaining consistent form',
                        Icons.star,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 30),
        const SizedBox(height: 8),
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

  Widget _buildInsightItem(String title, String description, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(description),
    );
  }
}
