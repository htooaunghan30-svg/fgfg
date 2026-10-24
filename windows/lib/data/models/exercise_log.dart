import 'package:isar/isar.dart';
import 'package:vector_math/vector_math.dart';

part 'exercise_log.g.dart';

@Collection()
class ExerciseLog {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String exerciseId;
  
  @Index()
  late DateTime timestamp;
  
  // Session level metrics
  late int sessionDuration; // in seconds
  late int totalRepetitions;
  late double averageAccuracy;
  late double maxAccuracy;
  late double minAccuracy;
  
  // Per–rep details and form warnings
  List<RepDetail> repDetails = [];
  List<FormWarning> formWarnings = [];
  
  // Premium metadata
  bool isPremiumSession = false;
  String? videoPath; // Path to recorded video (premium only)
  
  ExerciseLog({
    required this.exerciseId,
    required this.timestamp,
    required this.sessionDuration,
    required this.totalRepetitions,
    required this.averageAccuracy,
    required this.maxAccuracy,
    required this.minAccuracy,
    required this.repDetails,
    required this.formWarnings,
    this.isPremiumSession = false,
    this.videoPath,
  });
}

@embedded
class RepDetail {
  int repNumber;
  double accuracy;

  /// Duration of this rep in milliseconds
  int durationMs;

  /// Captured joint angles during the rep
  List<JointAngle> jointAngles;

  /// Whether this rep was performed with perfect form
  bool formPerfect;
  
  RepDetail({
    this.repNumber = 0,
    this.accuracy = 0.0,
    this.durationMs = 0,
    this.jointAngles = const [],
    this.formPerfect = true,
  });

  RepDetail copyWith({
    int? repNumber,
    double? accuracy,
    int? durationMs,
    List<JointAngle>? jointAngles,
    bool? formPerfect,
  }) {
    return RepDetail(
      repNumber: repNumber ?? this.repNumber,
      accuracy: accuracy ?? this.accuracy,
      durationMs: durationMs ?? this.durationMs,
      jointAngles: jointAngles ?? this.jointAngles,
      formPerfect: formPerfect ?? this.formPerfect,
    );
  }
}

@embedded
class JointAngle {
  String jointName;
  double angle;
  DateTime? timestamp;
  
  JointAngle({
    this.jointName = '',
    this.angle = 0.0,
    this.timestamp,
  });
}

@embedded
class FormWarning {
  String warningId;
  String message;
  DateTime? timestamp;
  List<double>? jointPosition;

  FormWarning({
    this.warningId = '',
    this.message = '',
    this.timestamp,
    this.jointPosition,
  });
}