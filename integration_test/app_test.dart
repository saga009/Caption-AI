import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_caption_generator_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Caption generation test', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tap on the first category (Selfie)
    await tester.tap(find.text('Selfie'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Enter description
    await tester.enterText(
      find.byType(TextField).first,
      'A beautiful sunset at the beach with golden light',
    );
    await tester.pumpAndSettle();

    // Tap generate button
    await tester.tap(find.text('Generate Caption ✨'));
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Verify result appears
    expect(find.text('Short Caption'), findsOneWidget);
  });
}
