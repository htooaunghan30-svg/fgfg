import 'package:isar/isar.dart';

part 'exercise_model.g.dart';

@Collection()
class ExerciseModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String exerciseId; // squat, pushup, etc
  
  late String name;
  late String type; // dynamic or static
  late String viewRequired; // side, front
  
  @Embedded()
  late RepLogic repLogic;
  
  List<FormCheck> formChecks = [];
  
  DateTime lastPerformed;// = DateTime.now();
  int totalReps = 0;
  double averageAccuracy = 0.0;
  
  ExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.type,
    required this.viewRequired,
    required this.repLogic,
    required this.formChecks,
    this.totalReps= 0,             // Default value ပေးထားလို့ရပါတယ်
    this.averageAccuracy = 0.0 ,
    required this.lastPerformed,
  });
}

@embedded
class RepLogic {
  String primaryJoint = 'knee';
  Phase? phase1Eccentric;
  Phase? phase2Concentric;
  HoldCondition? holdCondition; // For static exercises
  String? countType; // duration for static
  
  RepLogic({
    this.primaryJoint = 'knee',
    this.phase1Eccentric,
    this.phase2Concentric,
    this.holdCondition,
    this.countType,
  });
}

@embedded
class Phase {
  String condition = '';
  String description = '';
  double threshold = 0.0;
  
  Phase({
    this.condition = '',
    this.description = '',
    this.threshold = 0.0,
  });
}

@embedded
class HoldCondition {
  double? minKneeAngle;
  double? maxKneeAngle;
  double? minBackAngle;
  double? maxBackAngle;
  
  HoldCondition({
    this.minKneeAngle,
    this.maxKneeAngle,
    this.minBackAngle,
    this.maxBackAngle,
  });
}

@embedded
class FormCheck {
  String id = '';
  List<String> joints = [];
  String? checkType;
  String? targetJoint;
  List<String>? jointsPair;
  double? tolerance;
  double minAngle = 0.0;
  double maxAngle = 180.0;
  String warningMessage = '';
  
  FormCheck({
    this.id = '',
    this.joints = const [],
    this.checkType,
    this.targetJoint,
    this.jointsPair,
    this.tolerance,
    this.minAngle = 0.0,
    this.maxAngle = 0.0,
    this.warningMessage = '',
  });
}