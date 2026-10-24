// lib/core/utils/form_validator.dart
import 'package:vector_math/vector_math.dart';
import '../constants/exercise_config.dart';
import 'angle_calculator.dart';

class FormValidator {
  final AngleCalculator _angleCalculator = AngleCalculator();

  List<FormWarning> validateExerciseForm({
    required String exerciseId,
    required Map<String, double> jointAngles,
    required Map<String, Vector3> jointPositions,
  }) {
    final exerciseConfig = ExerciseConfig.getExerciseById(exerciseId);
    final formChecks = exerciseConfig['form_checks'] as List<dynamic>;
    final List<FormWarning> warnings = [];

    for (final check in formChecks) {
      final checkType = check['check_type'] as String?;
      
      if (checkType == 'symmetry') {
        warnings.addAll(_validateSymmetry(check, jointAngles));
      } else if (checkType == 'static_joint_position') {
        warnings.addAll(_validateStaticJoint(check, jointPositions));
      } else {
        warnings.addAll(_validateAngleRange(check, jointAngles));
      }
    }

    return warnings;
  }

  List<FormWarning> _validateAngleRange(
    Map<String, dynamic> check,
    Map<String, double> jointAngles,
  ) {
    final List<FormWarning> warnings = [];
    
    final id = check['id'] as String;
    final joints = (check['joints'] as List<dynamic>).cast<String>();
    final minAngle = (check['min_angle'] as num).toDouble();
    final maxAngle = (check['max_angle'] as num).toDouble();
    final warningMessage = check['warning_message'] as String;

    if (joints.length == 3) {
      final angleKey = '${joints[0]}_${joints[1]}_${joints[2]}';
      final angle = jointAngles[angleKey] ?? 0.0;

      if (angle < minAngle || angle > maxAngle) {
        warnings.add(FormWarning(
          warningId: id,
          message: warningMessage,
          timestamp: DateTime.now(),
        ));
      }
    }

    return warnings;
  }

  List<FormWarning> _validateSymmetry(
    Map<String, dynamic> check,
    Map<String, double> jointAngles,
  ) {
    final List<FormWarning> warnings = [];
    
    final id = check['id'] as String;
    final jointsPair = (check['joints_pair'] as List<dynamic>).cast<String>();
    final tolerance = (check['tolerance'] as num).toDouble();
    final warningMessage = check['warning_message'] as String;

    if (jointsPair.length == 2) {
      final leftAngle = jointAngles[jointsPair[0]] ?? 0.0;
      final rightAngle = jointAngles[jointsPair[1]] ?? 0.0;

      if ((leftAngle - rightAngle).abs() > tolerance) {
        warnings.add(FormWarning(
          warningId: id,
          message: warningMessage,
          timestamp: DateTime.now(),
        ));
      }
    }

    return warnings;
  }

  List<FormWarning> _validateStaticJoint(
    Map<String, dynamic> check,
    Map<String, Vector3> jointPositions,
  ) {
    final List<FormWarning> warnings = [];
    
    final id = check['id'] as String;
    final targetJoint = check['target_joint'] as String;
    final warningMessage = check['warning_message'] as String;

    // This would track joint movement over time
    // For now, return empty if we don't have historical data
    return warnings;
  }

  double calculateFormScore(List<FormWarning> warnings, int totalChecks) {
    if (totalChecks == 0) return 1.0;
    
    final errorCount = warnings.length;
    final score = 1.0 - (errorCount / totalChecks);
    return score.clamp(0.0, 1.0);
  }
}

class FormWarning {
  final String warningId;
  final String message;
  final DateTime timestamp;
  final Vector3? jointPosition;

  FormWarning({
    required this.warningId,
    required this.message,
    required this.timestamp,
    this.jointPosition,
  });
}