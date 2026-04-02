import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp());

    // Verify app starts with splash screen showing the app name
    expect(find.text('FitTrack'), findsOneWidget);
  });
}
