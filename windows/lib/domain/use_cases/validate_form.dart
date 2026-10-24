// lib/domain/use_cases/validate_form.dart
import 'package:vector_math/vector_math.dart';
import '../../core/utils/form_validator.dart';
import '../../data/models/exercise_log.dart'as data;
import 'dart:math';

class ValidateFormUseCase {
  final FormValidator _validator = FormValidator();
  
  List<FormWarning> validateExercise({
    required String exerciseId,
    required Map<String, double> jointAngles,
    required Map<String, Vector3> jointPositions,
  }) {
    return _validator.validateExerciseForm(
      exerciseId: exerciseId,
      jointAngles: jointAngles,
      jointPositions: jointPositions,
    );
  }
  
  double calculateFormScore({
    required List<FormWarning> warnings,
    required String exerciseId,
  }) {
    // Get total number of form checks for this exercise
    final formChecks = _getFormCheckCount(exerciseId);
    return _validator.calculateFormScore(warnings, formChecks);
  }
  
  int _getFormCheckCount(String exerciseId) {
    // This would come from exercise configuration
    // For now, return a default value
    return 2; // Most exercises have 2 form checks
  }
  
  Map<String, double> analyzeFormPatterns(List<data.ExerciseLog> logs) {
    if (logs.isEmpty) {
      return {
        'consistency': 0.0,
        'commonMistakes': 0.0,
        'improvementRate': 0.0,
      };
    }
    
    // Calculate consistency (standard deviation of accuracy)
    final accuracies = logs.map((log) => log.averageAccuracy).toList();
    final mean = accuracies.reduce((a, b) => a + b) / accuracies.length;
    final variance = accuracies
        .map((a) => (a - mean) * (a - mean))
        .reduce((a, b) => a + b) / accuracies.length;
    //final consistency = 1.0 - (variance.sqrt() / mean).clamp(0.0, 1.0);
   final consistency = 1.0 - (sqrt(variance) / (mean == 0 ? 1 : mean)).clamp(0.0, 1.0);
    
    // Calculate common mistakes ratio
    final totalReps = logs.fold(0, (sum, log) => sum + log.totalRepetitions);
    final totalWarnings = logs.fold(0, (sum, log) => sum + log.formWarnings.length);
    final commonMistakes = totalWarnings / totalReps;
    
    // Calculate improvement rate
    double improvementRate = 0.0;
    if (logs.length >= 2) {
      final sortedLogs = List<data.ExerciseLog>.from(logs)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      final firstAccuracy = sortedLogs.first.averageAccuracy;
      final lastAccuracy = sortedLogs.last.averageAccuracy;
      improvementRate = lastAccuracy - firstAccuracy;
    }
    
    return {
      'consistency': consistency,
      'commonMistakes': commonMistakes.clamp(0.0, 1.0),
      'improvementRate': improvementRate,
    };
  }
}