import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp(initialRoute: '/sign-in'));

    // Verify app starts with sign-in screen
    expect(find.text('FitTrack'), findsOneWidget);
  });
}
