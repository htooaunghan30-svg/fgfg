// lib/data/models/form_warning.dart
class FormWarning {
  final String warningId;
  final String message;
  final DateTime timestamp;
  
  FormWarning({
    required this.warningId,
    required this.message,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'warningId': warningId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}