import 'dart:math';
import 'package:vector_math/vector_math.dart';

/// Utilities for computing joint angles and basic kinematics.
class AngleCalculator {
  /// Calculate angle between three points (A, B, C) where B is the vertex.
  /// Returns angle in degrees in the range \[0, 180\].
  double calculateAngle(Vector3 a, Vector3 b, Vector3 c) {
    // Create vectors BA and BC
    final Vector3 ba = a - b;
    final Vector3 bc = c - b;
    
    // Calculate magnitudes
    final double magnitudeBA = ba.length;
    final double magnitudeBC = bc.length;
    
    // Avoid division by zero
    if (magnitudeBA == 0 || magnitudeBC == 0) {
      return 0.0;
    }
    
    // Calculate cosine of angle
    double cosTheta = ba.dot(bc) / (magnitudeBA * magnitudeBC);
    
    // Clamp to avoid floating point errors
    cosTheta = cosTheta.clamp(-1.0, 1.0);
    
    // Calculate angle in radians
    final double angleRad = acos(cosTheta);
    
    // Convert to degrees
    double angleDeg = degrees(angleRad);
    
    // Normalize to 0–180 range
    if (angleDeg > 180) {
      angleDeg = 360 - angleDeg;
    }
    
    return angleDeg;
  }
  
  /// Calculate 2D angle (ignoring z-coordinate).
  double calculate2DAngle(Vector3 a, Vector3 b, Vector3 c) {
    // Project to 2D by ignoring z-coordinate
    final Vector2 ba = Vector2(a.x - b.x, a.y - b.y);
    final Vector2 bc = Vector2(c.x - b.x, c.y - b.y);
    
    // Calculate using atan2 method for better stability
    final double angle1 = atan2(ba.y, ba.x);
    final double angle2 = atan2(bc.y, bc.x);
    
    double angleRad = angle1 - angle2;
    
    // Normalize to 0–π range
    angleRad = angleRad.abs();
    if (angleRad > pi) {
      angleRad = 2 * pi - angleRad;
    }
    
    return degrees(angleRad);
  }
  
  /// Check if three points are aligned (within tolerance in degrees).
  bool arePointsAligned(
    Vector3 a,
    Vector3 b,
    Vector3 c,
    double toleranceDegrees,
  ) {
    final double angle = calculateAngle(a, b, c);
    final double deviation = (angle - 180).abs();
    return deviation <= toleranceDegrees;
  }
  
  /// Calculate angular velocity between two angle measurements.
  /// Returns degrees per second.
  double calculateAngularVelocity(
    double angle1,
    double angle2,
    Duration timeDelta,
  ) {
    final double deltaAngle = (angle2 - angle1).abs();
    final double timeSeconds = timeDelta.inMilliseconds / 1000.0;
    
    if (timeSeconds == 0) return 0.0;
    
    return deltaAngle / timeSeconds;
  }
  
  /// More robust angle calculation helper that mirrors the logic
  /// used in the pose detection service.
  double calculateRobustAngle(Vector3 a, Vector3 b, Vector3 c) {
    try {
      final Vector3 ba = a - b;
      final Vector3 bc = c - b;
      
      // Check for zero vectors
      if (ba.length < 0.001 || bc.length < 0.001) {
        return 0.0;
      }
      
      // Normalize
      final Vector3 normBA = ba.normalized();
      final Vector3 normBC = bc.normalized();
      
      // Dot product and clamp
      double cosTheta = normBA.dot(normBC);
      cosTheta = cosTheta.clamp(-1.0, 1.0);
      
      // Calculate angle
      final double angleRad = acos(cosTheta);
      double angleDeg = degrees(angleRad);
      
      // Normalize to 0–180
      if (angleDeg > 180) {
        angleDeg = 360 - angleDeg;
      }
      
      // Basic sanity check for human joint angles
      if (angleDeg > 200 || angleDeg < 0) {
        return 0.0;
      }
      
      return angleDeg;
    } catch (e) {
      // In production we don't want angle failures to crash the app.
      print('Angle calculation error: $e');
      return 0.0;
    }
  }
}

