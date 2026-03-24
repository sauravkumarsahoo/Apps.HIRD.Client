import 'package:flutter_test/flutter_test.dart';
import 'package:hird/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Basic check to see if the app starts.
    expect(find.text('No network'), findsOneWidget);
  });
}
