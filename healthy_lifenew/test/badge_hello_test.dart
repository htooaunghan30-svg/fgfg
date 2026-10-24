import 'package:test/test.dart';

void main() {
  test('Badge awarded for reaching target', () {
    // Simulate reaching a target
    int target = 100;
    int current = 100;
    expect(awardBadge(current, target), true);
  });

  test('No badge awarded if target not reached', () {
    // Simulate not reaching a target
    int target = 100;
    int current = 50;
    expect(awardBadge(current, target), false);
  });

  test('Badge awarded for specific criteria', () {
    // Simulate specific criteria for badge
    int criteria = 10;
    int current = 10;
    expect(awardBadgeForCriteria(current, criteria), true);
  });

  test('No badge awarded for criteria not met', () {
    // Simulate criteria not met
    int criteria = 10;
    int current = 5;
    expect(awardBadgeForCriteria(current, criteria), false);
  });
}

bool awardBadge(int current, int target) {
  return current >= target;
}

bool awardBadgeForCriteria(int current, int criteria) {
  return current >= criteria;
}