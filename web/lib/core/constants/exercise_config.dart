// // lib/core/constants/exercise_config.dart
// class ExerciseConfig {
//   static final Map<String, dynamic> exercises = {
//     "metadata": {
//       "version": "1.0",
//       "description": "Fitness Logic for ML Kit Pose Detection",
//       "measurement_unit": "degrees"
//     },
//     "exercises": [
//       {
//         "id": "squat",
//         "name": "Squat",
//         "type": "dynamic",
//         "view_required": "side",
//         "rep_logic": {
//           "primary_joint": "knee",
//           "phase_1_eccentric": {
//             "condition": "angle < 100",
//             "description": "Squat Down (Depth)",
//             "threshold": 100
//           },
//           "phase_2_concentric": {
//             "condition": "angle > 160",
//             "description": "Stand Up",
//             "threshold": 160
//           }
//         },
//         "form_checks": [
//           {
//             "id": "depth_check",
//             "joints": ["hip", "knee", "ankle"],
//             "alternative_joints": ["right_hip", "right_knee", "right_ankle"], // Add this
//             "min_angle": 70,
//             "max_angle": 110,
//             "warning_message": "Go lower! Thighs parallel to floor.",
//             "weight"  : 1.0  // Add weight for importance

//           },
//           {
//             "id": "back_alignment",
//             "joints": ["shoulder", "hip", "knee"],
//             "min_angle": 150,
//             "max_angle": 180,
//             "warning_message": "Keep your back straight! Don't lean too forward.",
//                   "weight": 0.8  // Less weight than depth

//           }
//         ]
//       },
//       {
//         "id": "pushup",
//         "name": "Push-up",
//         "type": "dynamic",
//         "view_required": "side",
//         "rep_logic": {
//           "primary_joint": "elbow",
//           "phase_1_eccentric": {
//             "condition": "angle < 90",
//             "description": "Lower Body",
//             "threshold": 90
//           },
//           "phase_2_concentric": {
//             "condition": "angle > 160",
//             "description": "Push Up",
//             "threshold": 160
//           }
//         },
//         "form_checks": [
//           {
//             "id": "body_plank",
//             "joints": ["shoulder", "hip", "ankle"],
//             "alternative_joints": ["right_hip", "right_knee", "right_shoulder"],
//             "min_angle": 160,
//             "max_angle": 180,
//             "warning_message": "Fix your hips! Body should be a straight line."
//           }
//         ]
//       },
//       {
//         "id": "bicep_curl",
//         "name": "Bicep Curl",
//         "type": "dynamic",
//         "view_required": "side",
//         "rep_logic": {
//           "primary_joint": "elbow",
//           "phase_1_eccentric": {
//             "condition": "angle < 50",
//             "description": "Curl Up",
//             "threshold": 50
//           },
//           "phase_2_concentric": {
//             "condition": "angle > 160",
//             "description": "Lower Arm",
//             "threshold": 160
//           }
//         },
//         "form_checks": [
//           {
//             "id": "elbow_stability",
//             "joints": ["shoulder", "elbow", "wrist"],
//             "alternative_joints": ["right_shoulder", "right_elbow", "right_wrist"],
//             "check_type": "static_joint_position",
//             "target_joint": "elbow",
//             "warning_message": "Keep your elbows tucked to your side!"
//           }
//         ]
//       },
//       {
//         "id": "shoulder_press",
//         "name": "Shoulder Press",
//         "type": "dynamic",
//         "view_required": "front",
//         "rep_logic": {
//           "primary_joint": "elbow",
//           "phase_1_eccentric": {
//             "condition": "angle > 160",
//             "description": "Push Up (Extension)",
//             "threshold": 160
//           },
//           "phase_2_concentric": {
//             "condition": "angle < 90",
//             "description": "Lower Down",
//             "threshold": 90
//           }
//         },
//         "form_checks": [
//           {
//             "id": "arm_symmetry",
//             "check_type": "symmetry",
//             "joints_pair": ["left_elbow", "right_elbow"],
//             "alternative_joints": [],
//             "tolerance": 15,
//             "warning_message": "Push both arms evenly!"
//           }
//         ]
//       },
//       {
//         "id": "situp",
//         "name": "Sit-up",
//         "type": "dynamic",
//         "view_required": "side",
//         "rep_logic": {
//           "primary_joint": "hip",
//           "phase_1_eccentric": {
//             "condition": "angle < 60",
//             "description": "Sit Up",
//             "threshold": 60
//           },
//           "phase_2_concentric": {
//             "condition": "angle > 150",
//             "description": "Lay Down",
//             "threshold": 150
//           }
//         },
//         "form_checks": [
//           {
//             "id": "neck_strain",
//             "joints": ["ear", "shoulder", "hip"],
//             "alternative_joints": ["right_hip", "right_ear", "right_shoulder"],
//             "min_angle": 150,
//             "max_angle": 180,
//             "warning_message": "Don't pull your neck! Use your core."
//           }
//         ]
//       },
//       {
//         "id": "leg_extension",
//         "name": "Leg Extension",
//         "type": "dynamic",
//         "view_required": "side",
//         "rep_logic": {
//           "primary_joint": "knee",
//           "phase_1_eccentric": {
//             "condition": "angle > 160",
//             "description": "Extend Leg",
//             "threshold": 160
//           },
//           "phase_2_concentric": {
//             "condition": "angle < 100",
//             "description": "Lower Leg",
//             "threshold": 100
//           }
//         },
//         "form_checks": [
//           {
//             "id": "upper_body_stability",
//             "joints": ["shoulder", "hip", "knee"],
//             "alternative_joints": ["right_hip", "right_knee", "right_shoulder"],
//             "min_angle": 80,
//             "max_angle": 110,
//             "warning_message": "Keep your upper body still!"
//           }
//         ]
//       },
//         },
//         "form_checks": [
//           {
//             "id": "knee_angle_check",
//             "joints": ["hip", "knee", "ankle"],
//             "alternative_joints": ["right_hip", "right_knee", "right_ankle"],
//             "min_angle": 80,
//             "max_angle": 100,
//             "warning_message": "Thighs should be parallel to the ground (90Â°)."
//           }
//         ]
//       }
//     ]
//   };

//   static Map<String, dynamic> getExerciseById(String id) {
//     final exercisesList = exercises['exercises'] as List<dynamic>;
//     for (var exercise in exercisesList) {
//       if (exercise['id'] == id) {
//         return exercise as Map<String, dynamic>;
//       }
//     }
//     throw Exception('Exercise with id $id not found');
//   }

//   static List<Map<String, dynamic>> getAllExercises() {
//     return (exercises['exercises'] as List<dynamic>)
//         .cast<Map<String, dynamic>>();
//   }
// }



// lib/core/constants/exercise_config.dart
class ExerciseConfig {
  static final Map<String, dynamic> exercises = {
    "metadata": {
      "version": "1.1", // Version update
      "description": "Fitness Logic for ML Kit Pose Detection",
      "measurement_unit": "degrees",
      "accuracy_settings": {
        "min_threshold": 0.3,
        "good_threshold": 0.7,
        "excellent_threshold": 0.85,
        "rep_counting_threshold": 0.6 // Minimum accuracy for rep counting
      }
    },
    "exercises": [
      {
        "id": "squat",
        "name": "Squat",
        "type": "dynamic",
        "view_required": "side",
        "accuracy_calibration": {
          "standing": {"min": 160, "max": 180, "target": 180, "weight": 0.4},
          "quarter_squat": {"min": 140, "max": 160, "target": 150, "weight": 0.6},
          "half_squat": {"min": 100, "max": 140, "target": 120, "weight": 0.8},
          "parallel_squat": {"min": 80, "max": 100, "target": 90, "weight": 1.0},
          "deep_squat": {"min": 60, "max": 80, "target": 70, "weight": 0.9}
        },
        "rep_logic": {
          "primary_joint": "knee",
          "alternative_joints": ["left_knee", "right_knee"],
          "phase_1_eccentric": {
            "condition": "angle < 115",
            "description": "Squat Down (Depth)",
            "threshold": 112
          },
          "phase_2_concentric": {
            "condition": "angle > 140",
            "description": "Stand Up",
            "threshold": 145
          }
        },
        "form_checks": [
        ]
      },
      {
        "id": "pushup",
        "name": "Push-up",
        "type": "dynamic",
        "view_required": "side",
        "accuracy_calibration": {
          "top_position": {"min": 160, "max": 180, "target": 180, "weight": 0.4},
          "half_depth": {"min": 120, "max": 160, "target": 140, "weight": 0.7},
          "good_depth": {"min": 90, "max": 120, "target": 105, "weight": 0.9},
          "full_depth": {"min": 60, "max": 90, "target": 75, "weight": 0.8}
        },
        "rep_logic": {
          "primary_joint": "elbow",
          "alternative_joints": ["left_elbow", "right_elbow"],
          "phase_1_eccentric": {
            "condition": "angle < 110",
            "description": "Lower Body",
            "threshold": 110
          },
          "phase_2_concentric": {
            "condition": "angle > 115",
            "description": "Push Up",
            "threshold": 114
          }
        },
        "form_checks": [
          {
            "id": "body_plank",
            "joints": ["shoulder", "hip", "ankle"],
            "alternative_joints": ["right_shoulder", "right_hip", "right_ankle"],
            "min_angle": 160,
            "max_angle": 180,
            "warning_message": "",
            "weight": 1.0
          }
        ]
      },
      {
        "id": "bicep_curl",
        "name": "Bicep Curl",
        "type": "dynamic",
        "view_required": "side",
        "accuracy_calibration": {
          "extended": {"min": 160, "max": 180, "target": 180, "weight": 0.4},
          "mid_range": {"min": 90, "max": 160, "target": 125, "weight": 0.6},
          "peak_contraction": {"min": 30, "max": 90, "target": 60, "weight": 0.9},
          "full_curl": {"min": 20, "max": 50, "target": 35, "weight": 0.8}
        },
        "rep_logic": {
          "primary_joint": "elbow",
          "alternative_joints": ["left_elbow", "right_elbow"],
          "phase_1_eccentric": {
            "condition": "angle < 84",
            "description": "Curl Up",
            "threshold": 84
          },
          "phase_2_concentric": {
            "condition": "angle > 130",
            "description": "Lower Arm",
            "threshold": 130
          }
        },
        "form_checks": [
          {
            "id": "elbow_stability",
            "joints": ["shoulder", "elbow", "wrist"],
            "alternative_joints": ["right_shoulder", "right_elbow", "right_wrist"],
            "check_type": "static_joint_position",
            "target_joint": "elbow",
            "warning_message": "",
            "weight": 0.9
          }
        ]
      },
      {
        "id": "shoulder_press",
        "name": "Shoulder Press",
        "type": "dynamic",
        "view_required": "front",
        "accuracy_calibration": {
          "bottom_position": {"min": 70, "max": 100, "target": 85, "weight": 0.4},
          "mid_range": {"min": 100, "max": 140, "target": 120, "weight": 0.7},
          "top_position": {"min": 160, "max": 180, "target": 170, "weight": 0.9}
        },
        "rep_logic": {
          "primary_joint": "elbow",
          "alternative_joints": ["left_elbow", "right_elbow"],
          "phase_1_eccentric": {
            "condition": "angle > 160",
            "description": "Push Up (Extension)",
            "threshold": 160
          },
          "phase_2_concentric": {
            "condition": "angle < 90",
            "description": "Lower Down",
            "threshold": 90
          }
        },
        "form_checks": [
          {
            "id": "arm_symmetry",
            "check_type": "symmetry",
            "joints_pair": ["left_elbow", "right_elbow"],
            "alternative_joints": [],
            "tolerance": 15,
            "warning_message": "",
            "weight": 1.0
          }
        ]
      },
      {
        "id": "situp",
        "name": "Sit-up",
        "type": "dynamic",
        "view_required": "side",
        "accuracy_calibration": {
          "lying_down": {"min": 150, "max": 180, "target": 170, "weight": 0.4},
          "mid_range": {"min": 100, "max": 150, "target": 125, "weight": 0.7},
          "sitting_up": {"min": 60, "max": 100, "target": 80, "weight": 0.9},
          "full_situp": {"min": 40, "max": 60, "target": 50, "weight": 0.8}
        },
        "rep_logic": {
          "primary_joint": "hip",
          "alternative_joints": ["left_hip", "right_hip"],
          "phase_1_eccentric": {
            "condition": "angle < 60",
            "description": "Sit Up",
            "threshold": 60
          },
          "phase_2_concentric": {
            "condition": "angle > 150",
            "description": "Lay Down",
            "threshold": 150
          }
        },
        "form_checks": [
          {
            "id": "neck_strain",
            "joints": ["ear", "shoulder", "hip"],
            "alternative_joints": ["right_ear", "right_shoulder", "right_hip"],
            "min_angle": 150,
            "max_angle": 180,
            "warning_message": "",
            "weight": 0.9
          },
          {
            "id": "feet_stability",
            "joints": ["hip", "knee", "ankle"],
            "min_angle": 80,
            "max_angle": 110,
            "warning_message": "",
            "weight": 0.6
          }
        ]
      },
      {
        "id": "leg_extension",
        "name": "Leg Extension",
        "type": "dynamic",
        "view_required": "side",
        "accuracy_calibration": {
          "flexed": {"min": 80, "max": 120, "target": 100, "weight": 0.4},
          "mid_range": {"min": 120, "max": 150, "target": 135, "weight": 0.7},
          "extended": {"min": 150, "max": 180, "target": 165, "weight": 0.9}
        },
        'leg_extension_settings': {  // á€¡á€…á€ºá€€á€­á€¯á€· code á€‘á€²á€™á€¾á€¬ á€’á€® key á€€á€­á€¯ á€˜á€¯á€¶á€žá€¯á€¶á€¸á€‘á€¬á€¸á€œá€­á€¯á€·á€•á€«
    'min_range_of_motion': 30.0, // ðŸ‘ˆ á€’á€®á€á€”á€ºá€–á€­á€¯á€¸á€€á€­á€¯ á‡á€ á€‘á€¬á€¸á€œá€­á€¯á€€á€ºá€•á€«
    'min_rep_duration_ms': 1200,
    'noise_buffer_ms': 1200,
  },
        "rep_logic": {
          "primary_joint": "knee",
          "alternative_joints": ["left_knee", "right_knee"],
          
          "phase_2_concentric": {
            "condition": "angle > 150",
            "description": "Extend Leg",
            "threshold": 150
          },
          "phase_1_eccentric": {
            "condition": "angle < 120",
            "description": "Lower Leg",
            "threshold": 120
          }
        },
        "form_checks": [
          {
            "id": "upper_body_stability",
            "joints": ["shoulder", "hip", "knee"],
            "alternative_joints": ["right_shoulder", "right_hip", "right_knee"],
            "min_angle": 80,
            "max_angle": 110,
            "warning_message": "",
            "weight": 0.9
          },
          {
            "id": "hip_stability",
            "joints": ["ear", "shoulder", "hip"],
            "min_angle": 160,
            "max_angle": 180,
            "warning_message": "",
            "weight": 0.8
          }
        ]
      },
      {
        "id": "bench_press",
        "name": "Bench Press",
        "type": "dynamic",
        "view_required": "side",
        "accuracy_calibration": {
          "top_position": {"min": 160, "max": 180, "target": 175, "weight": 0.4},
          "half_depth": {"min": 110, "max": 140, "target": 125, "weight": 0.6},
          "good_depth": {"min": 85, "max": 110, "target": 95, "weight": 0.9},
          "full_depth": {"min": 60, "max": 85, "target": 75, "weight": 1.0}
        },
        "rep_logic": {
          "primary_joint": "elbow",
          "alternative_joints": ["left_elbow", "right_elbow"],
          "phase_1_eccentric": {
            "condition": "angle < 102",
            "description": "Lower Bar to Chest",
            "threshold": 102
          },
          "phase_2_concentric": {
            "condition": "angle > 118",
            "description": "Push Bar Up",
            "threshold": 145
          }
        },
        "form_checks": [
          {
            "id": "full_extension",
            "joints": ["shoulder", "elbow", "wrist"],
            "min_angle": 160,
            "max_angle": 180,
            "warning_message": "Lock your elbows at the top",
            "weight": 0.5
          }
        ]
      },
      {
        "id": "lateral_raise",
        "name": "Lateral Raise",
        "type": "dynamic",
        "view_required": "front",
        "accuracy_calibration": {
          "bottom_position": {"min": 0, "max": 25, "target": 15, "weight": 0.3},
          "mid_way": {"min": 40, "max": 60, "target": 50, "weight": 0.5},
          "target_height": {"min": 80, "max": 95, "target": 85, "weight": 1.0},
          "over_extension": {"min": 100, "max": 180, "target": 110, "weight": 0.7}
        },
        "rep_logic": {
          "primary_joint": "shoulder",
          "note": "Angle between Hip, Shoulder, and Elbow",
          "alternative_joints": ["left_shoulder", "right_shoulder"],
          "phase_1_concentric": {
            "condition": "angle > 80",
            "description": "Raise arms to shoulder level",
            "threshold": 80
          },
          "phase_2_eccentric": {
            "condition": "angle < 80",
            "description": "Lower arms slowly",
            "threshold": 35
          }
        },
        "form_checks": [
          {
            "id": "straight_arms",
            "joints": ["shoulder", "elbow", "wrist"],
            "min_angle": 140,
            "max_angle": 180,
            "warning_message": "Don't bend your elbows too much",
            "weight": 0.8
          },
          {
            "id": "excessive_height",
            "joints": ["hip", "shoulder", "elbow"],
            "min_angle": 0,
            "max_angle": 105,
            "warning_message": "Stop at shoulder height to avoid injury",
            "weight": 0.6
          }
        ]
      },
      {
        "id": "front_raise",
        "name": "Front Raise",
        "type": "dynamic",
        "view_required": "front",
        "accuracy_calibration": {
          "bottom_position": {"min": 0, "max": 25, "target": 15, "weight": 0.3},
          "mid_way": {"min": 40, "max": 60, "target": 50, "weight": 0.5},
          "target_height": {"min": 80, "max": 95, "target": 85, "weight": 1.0},
          "over_extension": {"min": 100, "max": 180, "target": 110, "weight": 0.7}
        },
        "rep_logic": {
          "primary_joint": "shoulder",
          "note": "Uses the same shoulder-angle logic as lateral raise",
          "alternative_joints": ["left_shoulder", "right_shoulder"],
          "phase_1_concentric": {
            "condition": "angle > 80",
            "description": "Raise arms to shoulder level",
            "threshold": 80
          },
          "phase_2_eccentric": {
            "condition": "angle < 35",
            "description": "Lower arms slowly",
            "threshold": 35
          }
        },
        "form_checks": [
          {
            "id": "straight_arms",
            "joints": ["shoulder", "elbow", "wrist"],
            "min_angle": 140,
            "max_angle": 180,
            "warning_message": "Don't bend your elbows too much",
            "weight": 0.8
          },
          {
            "id": "excessive_height",
            "joints": ["hip", "shoulder", "elbow"],
            "min_angle": 0,
            "max_angle": 105,
            "warning_message": "Stop at shoulder height to avoid injury",
            "weight": 0.6
          }
        ]
      },
    ]
  };

  static Map<String, dynamic> getExerciseById(String id) {
    final exercisesList = exercises['exercises'] as List<dynamic>;
    for (var exercise in exercisesList) {
      if (exercise['id'] == id) {
        return exercise as Map<String, dynamic>;
      }
    }
    throw Exception('Exercise with id $id not found');
  }

  static List<Map<String, dynamic>> getAllExercises() {
    return (exercises['exercises'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }
  
  // New method to get accuracy calibration
  static Map<String, dynamic>? getAccuracyCalibration(String exerciseId) {
    final exercise = getExerciseById(exerciseId);
    return exercise['accuracy_calibration'] as Map<String, dynamic>?;
  }
}

