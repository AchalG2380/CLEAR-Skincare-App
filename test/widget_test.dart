// This is a basic Flutter widget test for the Clear application.

import 'package:flutter_test/flutter_test.dart';
import 'package:clear/main.dart';
import 'package:get/get.dart';
import 'package:clear/core/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(ThemeController());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen shows the title "Clear".
    expect(find.text('Clear'), findsOneWidget);

    // Let the splash screen timer complete (3 seconds) to clean up pending timers
    await tester.pump(const Duration(seconds: 3));
  });
}
