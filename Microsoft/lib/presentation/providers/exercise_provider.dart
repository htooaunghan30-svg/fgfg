import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import '../../domain/repositories/exercise_repository_impl.dart';
import '../../domain/use_cases/track_exercise.dart';
import '../../domain/use_cases/validate_form.dart';
import '../../domain/use_cases/calculate_metrics.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/exercise_log.dart' as data;
import '../../data/models/user_activity.dart';
import '../../core/utils/form_validator.dart';
import '../../core/constants/exercise_config.dart';
import '../../core/utils/calorie_estimator.dart';

class ExerciseProvider with ChangeNotifier {
  final ExerciseRepositoryImpl repository;
  final TrackExerciseUseCase trackExerciseUseCase;
  final ValidateFormUseCase validateFormUseCase;
  final CalculateMetricsUseCase calculateMetricsUseCase;

  ExerciseProvider({
    required this.repository,
    required this.trackExerciseUseCase,
    required this.validateFormUseCase,
    required this.calculateMetricsUseCase,
  });

  // State
  List<ExerciseModel> _exercises = [];
  Map<String, List<data.ExerciseLog>> _exerciseLogs = {};
  UserActivity? _todayActivity;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  Future<void>? _initializeFuture;

  // Getters
  List<ExerciseModel> get exercises => _exercises;
  UserActivity? get todayActivity => _todayActivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Streams
  Stream<List<data.ExerciseLog>>? _logsStream;
  StreamSubscription<List<data.ExerciseLog>>? _logsSubscription;

  // For tracking today's stats
  int _todayTotalReps = 0;
  int _todayWorkoutCount = 0;
  double _todayEstimatedCalories = 0.0;
  DateTime? _lastTodayStatsDate;
  Timer? _dayRolloverTimer;

  int get todayTotalReps => _todayTotalReps;
  int get todayWorkoutCount => _todayWorkoutCount;
  double get todayEstimatedCalories => _todayEstimatedCalories;

  // Initialization
  Future<void> initialize({bool forceRefresh = false}) {
    if (!forceRefresh) {
      if (_isInitialized) {
        return Future.value();
      }
      final inflight = _initializeFuture;
      if (inflight != null) {
        return inflight;
      }
    }

    _initializeFuture = _initializeInternal(forceRefresh: forceRefresh);
    return _initializeFuture!;
  }

  Future<void> _initializeInternal({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (forceRefresh) {
        await _logsSubscription?.cancel();
        _logsSubscription = null;
        _logsStream = null;
      }

      // Load all exercises
      _exercises = await repository.getAllExercises();
      print('âœ… Loaded ${_exercises.length} exercises');

      // Load today's activity
      _todayActivity = await repository.getOrCreateDailyActivity();
      print('âœ… Today activity: ${_todayActivity?.totalRepetitions} reps');

      // Load initial logs
      await _loadInitialLogs();

      // Subscribe to exercise logs
      _startLogsSubscription();
      _scheduleDayRolloverRefresh();

      _error = null;
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize: $e';
      _isInitialized = false;
      print('âŒ Error in initialize: $e');
    } finally {
      _isLoading = false;
      _initializeFuture = null;
      notifyListeners();
    }
  }

  Future<void> _loadInitialLogs() async {
    try {
      // Load logs from the last 7 days
      final logs = await repository.getExerciseLogsByDateRange(
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now(),
      );

      print('ðŸ“Š Initial logs loaded: ${logs.length}');

      // Group logs by exercise ID
      _exerciseLogs.clear();
      for (final log in logs) {
        _exerciseLogs.putIfAbsent(log.exerciseId, () => []).add(log);
      }

      // Calculate today's stats
      _calculateTodayStats();
    } catch (e) {
      print('Error loading initial logs: $e');
    }
  }

  List<data.ExerciseLog> getExerciseLogs(String exerciseId) {
    return _exerciseLogs[exerciseId] ?? [];
  }

  Future<List<UserActivity>> getWeeklyProgress() async {
    return await repository.getWeeklyActivities();
  }

  Future<List<UserActivity>> getMonthlyProgress() async {
    return await repository.getMonthlyActivities();
  }

// exercise_provider.dart á€‘á€²á€™á€¾á€¬ á€’á€® method á€€á€­á€¯ á€•á€¼á€„á€ºá€•á€«

  Stream<List<data.ExerciseLog>> watchExerciseLogs({String? exerciseId}) {
    if (exerciseId != null) {
      // Specific exercise á€¡á€á€½á€€á€º
      return repository.watchExerciseLogs(exerciseId: exerciseId);
    } else {
      // All exercises á€¡á€á€½á€€á€º
      return repository.watchExerciseLogs();
    }
  }

  void _startLogsSubscription() {
    if (_logsSubscription != null) {
      return;
    }
    _logsStream = repository.watchExerciseLogs();
    _logsSubscription = _logsStream?.listen((logs) async {
      print('ðŸ“¥ Stream received ${logs.length} logs');

      // Group logs by exercise ID
      _exerciseLogs.clear();
      for (final log in logs) {
        _exerciseLogs.putIfAbsent(log.exerciseId, () => []).add(log);
      }

      // Calculate today's stats
      _calculateTodayStats();

      // Refresh exercise models so Total Reps / Accuracy / Last Performed update.
      try {
        _exercises = await repository.getAllExercises();
      } catch (e) {
        print('Error refreshing exercises: $e');
      }

      notifyListeners();
    }, onError: (error) {
      print('âŒ Error in logs stream: $error');
    });
  }

  void _calculateTodayStats() {
    final now = DateTime.now();
    _lastTodayStatsDate = DateTime(now.year, now.month, now.day);
    final todayLogs = getExerciseLogsForToday();
    final completedLogs =
        todayLogs.where((log) => (log.totalRepetitions ?? 0) > 0).toList();

    _todayTotalReps = completedLogs.fold(
      0,
      (sum, log) => sum + (log.totalRepetitions ?? 0),
    );
    _todayWorkoutCount = completedLogs.length;
    _todayEstimatedCalories = completedLogs.fold(
      0.0,
      (sum, log) => sum + _estimateCaloriesFromLog(log),
    );

    print(
      'ðŸ“ˆ Today stats calculated: $_todayTotalReps reps, $_todayWorkoutCount workouts, '
      '${_todayEstimatedCalories.toStringAsFixed(2)} kcal',
    );
  }

  void _scheduleDayRolloverRefresh() {
    _dayRolloverTimer?.cancel();

    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    // Buffer ensures we cross the day boundary before recalculating.
    final delay = tomorrow.difference(now) + const Duration(seconds: 1);

    _dayRolloverTimer = Timer(delay, () async {
      final rolloverNow = DateTime.now();
      final rolloverDay =
          DateTime(rolloverNow.year, rolloverNow.month, rolloverNow.day);
      if (_lastTodayStatsDate == rolloverDay) {
        _scheduleDayRolloverRefresh();
        return;
      }

      try {
        _todayActivity = await repository.getOrCreateDailyActivity();
      } catch (e) {
        print('Error refreshing today activity: $e');
      }

      _calculateTodayStats();
      notifyListeners();
      _scheduleDayRolloverRefresh();
    });
  }

  double _estimateCaloriesFromLog(data.ExerciseLog log) {
    return ExerciseCalorieEstimator.estimateFromLog(
      exerciseId: log.exerciseId,
      totalRepetitions: log.totalRepetitions,
      sessionDurationSeconds: log.sessionDuration,
      repDurationsMs: log.repDetails.map((rep) => rep.durationMs).toList(),
    );
  }

  // Get today's exercise logs
  List<data.ExerciseLog> getExerciseLogsForToday() {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      print('ðŸ” Looking for logs between $today and $tomorrow');

      final todayLogs = _exerciseLogs.values
          .expand((logs) => logs)
          .where(
            (log) =>
                !log.timestamp.isBefore(today) &&
                log.timestamp.isBefore(tomorrow),
          )
          .toList();

      print('ðŸ“… Found ${todayLogs.length} logs for today');

      // Debug: List each log
      for (final log in todayLogs) {
        print(
            '  - ${log.exerciseId}: ${log.totalRepetitions} reps at ${log.timestamp}');
      }

      return todayLogs;
    } catch (e) {
      print('Error in getExerciseLogsForToday: $e');
      return [];
    }
  }

  // Get exercise by ID
  ExerciseModel? getExerciseById(String exerciseId) {
    try {
      return _exercises.firstWhere(
        (exercise) => exercise.exerciseId == exerciseId,
      );
    } catch (e) {
      print('Exercise not found: $exerciseId');
      return null;
    }
  }

  // Create default exercise if not found
  ExerciseModel _createDefaultExercise(String exerciseId) {
    final config = ExerciseConfig.getExerciseById(exerciseId);

    if (config != null) {
      return ExerciseModel(
        exerciseId: config['id'] as String,
        name: config['name'] as String,
        type: config['type'] as String,
        viewRequired: config['view_required'] as String,
        repLogic: _convertConfigToRepLogic(config['rep_logic']),
        formChecks: _convertConfigToFormChecks(config['form_checks']),
        totalReps: 0,
        averageAccuracy: 0.0,
        lastPerformed: DateTime.now(),
      );
    }

    return ExerciseModel(
      exerciseId: exerciseId,
      name: exerciseId.replaceAll('_', ' ').toUpperCase(),
      type: 'dynamic',
      viewRequired: 'side',
      repLogic: RepLogic(primaryJoint: 'knee'),
      formChecks: [],
      totalReps: 0,
      averageAccuracy: 0.0,
      lastPerformed: DateTime.now(),
    );
  }

  // Helper: Convert config to RepLogic
  RepLogic _convertConfigToRepLogic(dynamic repLogicConfig) {
    if (repLogicConfig == null || repLogicConfig is! Map<String, dynamic>) {
      return RepLogic();
    }

    if (repLogicConfig['count_type'] == 'duration') {
      final holdCondition =
          repLogicConfig['hold_condition'] as Map<String, dynamic>? ?? {};

      return RepLogic(
        countType: 'duration',
        holdCondition: HoldCondition(
          minKneeAngle:
              (holdCondition['min_knee_angle'] as num?)?.toDouble() ?? 80.0,
          maxKneeAngle:
              (holdCondition['max_knee_angle'] as num?)?.toDouble() ?? 100.0,
          minBackAngle:
              (holdCondition['min_back_angle'] as num?)?.toDouble() ?? 170.0,
          maxBackAngle:
              (holdCondition['max_back_angle'] as num?)?.toDouble() ?? 180.0,
        ),
      );
    } else {
      final phase1 = (repLogicConfig['phase_1_eccentric'] ??
              repLogicConfig['phase_1_concentric'])
          as Map<String, dynamic>? ??
          {};
      final phase2 = (repLogicConfig['phase_2_concentric'] ??
              repLogicConfig['phase_2_eccentric'])
          as Map<String, dynamic>? ??
          {};

      return RepLogic(
        primaryJoint: repLogicConfig['primary_joint'] as String? ?? 'knee',
        phase1Eccentric: Phase(
          condition: phase1['condition'] as String? ?? 'angle < 100',
          description: phase1['description'] as String? ?? 'Down',
          threshold: (phase1['threshold'] as num?)?.toDouble() ?? 100.0,
        ),
        phase2Concentric: Phase(
          condition: phase2['condition'] as String? ?? 'angle > 160',
          description: phase2['description'] as String? ?? 'Up',
          threshold: (phase2['threshold'] as num?)?.toDouble() ?? 160.0,
        ),
      );
    }
  }

  // Helper: Convert config to FormChecks
  List<FormCheck> _convertConfigToFormChecks(dynamic formChecksConfig) {
    if (formChecksConfig == null || formChecksConfig is! List<dynamic>) {
      return [];
    }

    return formChecksConfig.map<FormCheck>((check) {
      final Map<String, dynamic> c = check as Map<String, dynamic>;

      return FormCheck(
        id: c['id'] as String? ?? '',
        joints: (c['joints'] as List<dynamic>?)?.cast<String>() ?? [],
        checkType: c['check_type'] as String?,
        targetJoint: c['target_joint'] as String?,
        jointsPair: (c['joints_pair'] as List<dynamic>?)?.cast<String>() ?? [],
        minAngle: (c['min_angle'] as num?)?.toDouble() ?? 0.0,
        maxAngle: (c['max_angle'] as num?)?.toDouble() ?? 180.0,
        tolerance: (c['tolerance'] as num?)?.toDouble() ?? 15.0,
        warningMessage: c['warning_message'] as String? ?? 'Check your form!',
      );
    }).toList();
  }

  Future<void> saveExerciseSession({
    required String exerciseId,
    required int totalReps,
    required Duration sessionDuration,
    required double averageAccuracy,
    required List<Map<String, dynamic>> repDetails,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final repDetailObjects = repDetails.map((detail) {
        final int repNumber = detail['repNumber'] as int? ?? 0;
        final double accuracy = (detail['accuracy'] as num?)?.toDouble() ?? 0.0;
        final int durationSeconds = detail['duration'] as int? ?? 0;

        return data.RepDetail(
          repNumber: repNumber,
          accuracy: accuracy,
          durationMs: durationSeconds * 1000,
          jointAngles: const [],
          formPerfect: true,
        );
      }).toList();

      final log = data.ExerciseLog(
        exerciseId: exerciseId,
        timestamp: DateTime.now(),
        sessionDuration: sessionDuration.inSeconds,
        totalRepetitions: totalReps,
        averageAccuracy: averageAccuracy,
        maxAccuracy: averageAccuracy,
        minAccuracy: averageAccuracy,
        repDetails: repDetailObjects,
        formWarnings: [],
      );

      await repository.saveExerciseLog(log);

      final exercise = getExerciseById(exerciseId);
      if (exercise != null) {
        final prevTotalReps = exercise.totalReps;
        final newTotalReps = prevTotalReps + totalReps;
        final weightedSum =
            (exercise.averageAccuracy * prevTotalReps) +
                (averageAccuracy * totalReps);
        exercise.totalReps = newTotalReps;
        exercise.averageAccuracy =
            newTotalReps > 0 ? (weightedSum / newTotalReps) : 0.0;
        exercise.lastPerformed = DateTime.now();
        await repository.saveExercise(exercise);
      }

      _todayActivity = await repository.getOrCreateDailyActivity();
      _todayActivity!.addWorkout(
        exerciseId: exerciseId,
        reps: totalReps,
        duration: sessionDuration,
        accuracy: averageAccuracy,
      );
      await repository.updateDailyActivity(_todayActivity!);

      await _refreshExerciseData();

      _error = null;
      print(
          'âœ… Exercise session saved: $totalReps reps, $averageAccuracy% accuracy');
    } catch (e) {
      _error = 'Failed to save exercise session: $e';
      print('âŒ Error in saveExerciseSession: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshExerciseData() async {
    try {
      _exercises = await repository.getAllExercises();
      _todayActivity = await repository.getOrCreateDailyActivity();

      final logs = await repository.getExerciseLogsByDateRange(
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );

      _exerciseLogs.clear();
      for (final log in logs) {
        _exerciseLogs.putIfAbsent(log.exerciseId, () => []).add(log);
      }

      _calculateTodayStats();

      print(
          'ðŸ”„ Refreshed exercise data: ${_exercises.length} exercises, ${logs.length} logs');
    } catch (e) {
      print('Error refreshing exercise data: $e');
    }
  }

  // Cleanup
  @override
  void dispose() {
    _logsSubscription?.cancel();
    _dayRolloverTimer?.cancel();
    _isInitialized = false;
    _initializeFuture = null;
    super.dispose();
  }
}
