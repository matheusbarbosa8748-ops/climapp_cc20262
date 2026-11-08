import 'package:flutter_test/flutter_test.dart';
import 'package:climapp_cc20262/main.dart';

void main() {
  testWidgets('App smoke test loads LocationScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the location loading state is rendered.
    expect(find.text('Obtendo sua localização...'), findsOneWidget);
  });
}
