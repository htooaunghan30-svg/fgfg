import 'package:test/test.dart';

void main() {
  group('Badge System Tests', () {
    test('Award badge for reaching target', () {
      // Simulate reaching a target
      var result = awardBadge(100); // Assuming 100 is the target
      expect(result, equals('Badge Awarded'));
    });

    test('No badge awarded for below target', () {
      // Simulate not reaching a target
      var result = awardBadge(50); // Assuming 100 is the target
      expect(result, equals('No Badge'));
    });

    test('Edge case: exactly at target', () {
      // Simulate exactly reaching the target
      var result = awardBadge(100); // Assuming 100 is the target
      expect(result, equals('Badge Awarded'));
    });

    test('Multiple badges awarded correctly', () {
      // Simulate multiple targets
      var result1 = awardBadge(100);
      var result2 = awardBadge(200);
      expect(result1, equals('Badge Awarded'));
      expect(result2, equals('Badge Awarded'));
    });
  });
}

String awardBadge(int score) {
  if (score >= 100) {
    return 'Badge Awarded';
  } else {
    return 'No Badge';
  }
}