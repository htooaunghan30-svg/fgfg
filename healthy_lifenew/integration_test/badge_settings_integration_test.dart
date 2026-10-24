import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_lifenew/main.dart';

void main() {
  testWidgets('Badge settings integration test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Simulate user interaction with badge settings
    // Example: Navigate to badge settings and check if badges are displayed
    await tester.tap(find.byKey(Key('badgeSettingsButton')));
    await tester.pumpAndSettle();

    // Verify that the badges are displayed correctly
    expect(find.byKey(Key('badge1')), findsOneWidget);
    expect(find.byKey(Key('badge2')), findsOneWidget);

    // Simulate conditions to award badges
    // Example: Complete a task that should award a badge
    await tester.tap(find.byKey(Key('completeTaskButton')));
    await tester.pumpAndSettle();

    // Verify that the badge is awarded
    expect(find.byKey(Key('badge1Awarded')), findsOneWidget);
  });
}