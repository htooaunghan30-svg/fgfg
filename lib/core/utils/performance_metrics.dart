// lib/core/utils/performance_metrics.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

class PerformanceMetrics {
  // Singleton instance
  static final PerformanceMetrics _instance = PerformanceMetrics._internal();
  factory PerformanceMetrics() => _instance;
  PerformanceMetrics._internal();

  // Performance tracking
  final List<double> _frameTimes = [];
  final List<double> _detectionTimes = [];
  final List<double> _angleCalculationTimes = [];
  static const int _maxSamples = 100;

  // Memory usage tracking
  int _totalMemoryUsed = 0;
  final Map<String, int> _componentMemory = {};

  void recordFrameTime(double milliseconds) {
    _frameTimes.add(milliseconds);
    if (_frameTimes.length > _maxSamples) {
      _frameTimes.removeAt(0);
    }
  }

  void recordDetectionTime(double milliseconds) {
    _detectionTimes.add(milliseconds);
    if (_detectionTimes.length > _maxSamples) {
      _detectionTimes.removeAt(0);
    }
  }

  void recordAngleCalculationTime(double milliseconds) {
    _angleCalculationTimes.add(milliseconds);
    if (_angleCalculationTimes.length > _maxSamples) {
      _angleCalculationTimes.removeAt(0);
    }
  }

  void trackMemoryUsage(String component, int bytes) {
    _componentMemory[component] = bytes;
    _totalMemoryUsed = _componentMemory.values.fold(0, (sum, bytes) => sum + bytes);
  }

  Map<String, dynamic> getPerformanceReport() {
    return {
      'fps': _calculateAverageFps(),
      'averageFrameTime': _calculateAverage(_frameTimes),
      'averageDetectionTime': _calculateAverage(_detectionTimes),
      'averageAngleTime': _calculateAverage(_angleCalculationTimes),
      'memoryUsage': _totalMemoryUsed,
      'componentMemory': Map.from(_componentMemory),
      'isPerformanceOptimal': _isPerformanceOptimal(),
    };
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateAverageFps() {
    if (_frameTimes.isEmpty) return 0.0;
    final avgFrameTime = _calculateAverage(_frameTimes);
    return avgFrameTime > 0 ? 1000 / avgFrameTime : 0;
  }

  bool _isPerformanceOptimal() {
    final fps = _calculateAverageFps();
    final avgDetectionTime = _calculateAverage(_detectionTimes);
    
    return fps >= 20 && avgDetectionTime < 33; // 30 FPS target
  }

  // Energy consumption estimation
  double estimateEnergyConsumption(Duration sessionDuration) {
    final minutes = sessionDuration.inMinutes;
    final fps = _calculateAverageFps();
    
    // Rough estimation formula
    double energy = 0.0;
    
    if (fps > 30) {
      energy = minutes * 0.15; // High processing
    } else if (fps > 20) {
      energy = minutes * 0.10; // Medium processing
    } else {
      energy = minutes * 0.07; // Low processing
    }
    
    return energy;
  }

  // Prediction for battery life
  String predictBatteryLife(int batteryPercentage) {
    final avgEnergyPerMinute = estimateEnergyConsumption(const Duration(minutes: 1));
    
    if (avgEnergyPerMinute == 0) return 'Unable to estimate';
    
    final remainingMinutes = (batteryPercentage / 100) / avgEnergyPerMinute;
    
    if (remainingMinutes > 120) {
      return '${(remainingMinutes / 60).toStringAsFixed(1)} hours';
    } else {
      return '${remainingMinutes.toStringAsFixed(0)} minutes';
    }
  }

  void clear() {
    _frameTimes.clear();
    _detectionTimes.clear();
    _angleCalculationTimes.clear();
    _componentMemory.clear();
    _totalMemoryUsed = 0;
  }
}

// Performance monitoring widget
class PerformanceMonitor with ChangeNotifier {
  final PerformanceMetrics _metrics = PerformanceMetrics();
  bool _isMonitoring = false;
  Map<String, dynamic> _lastReport = {};

  bool get isMonitoring => _isMonitoring;
  Map<String, dynamic> get lastReport => _lastReport;

  void startMonitoring() {
    _isMonitoring = true;
    notifyListeners();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
  }

  void updateReport() {
    _lastReport = _metrics.getPerformanceReport();
    notifyListeners();
  }

  void recordMetric(String type, double value) {
    switch (type) {
      case 'frame':
        _metrics.recordFrameTime(value);
        break;
      case 'detection':
        _metrics.recordDetectionTime(value);
        break;
      case 'angle':
        _metrics.recordAngleCalculationTime(value);
        break;
    }
    
    if (_isMonitoring) {
      updateReport();
    }
  }

  String getPerformanceStatus() {
    final report = _metrics.getPerformanceReport();
    final fps = report['fps'] as double;
    
    if (fps >= 25) {
      return 'Excellent';
    } else if (fps >= 20) {
      return 'Good';
    } else if (fps >= 15) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }
}