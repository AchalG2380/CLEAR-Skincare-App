import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:clear/core/controllers/comparison_controller.dart';
import 'package:clear/product_comparison/screens/comparison_screen.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('ComparisonController toggles items and enforces limit of 3', (WidgetTester tester) async {
    final controller = Get.put(ComparisonController());

    // Initially empty
    expect(controller.comparedIds.length, 0);

    // Toggle add
    controller.toggleCompare('p1');
    expect(controller.comparedIds.length, 1);
    expect(controller.isCompared('p1'), true);

    // Toggle remove
    controller.toggleCompare('p1');
    expect(controller.comparedIds.length, 0);
    expect(controller.isCompared('p1'), false);

    // Add 3 products
    controller.toggleCompare('p1');
    controller.toggleCompare('p2');
    controller.toggleCompare('p3');
    expect(controller.comparedIds.length, 3);

    // Try to add a 4th - should trigger snackbar but keep length at 3
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => controller.toggleCompare('p4'),
              child: const Text('Add 4th'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add 4th'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    // Verify limit is still 3
    expect(controller.comparedIds.length, 3);
    expect(controller.isCompared('p4'), false);

    // Clear
    controller.clearComparison();
    expect(controller.comparedIds.length, 0);
  });

  testWidgets('ComparisonScreen displays empty state when less than 2 items are selected', (WidgetTester tester) async {
    Get.put(ComparisonController());
    
    // Pump screen with 0 items
    await tester.pumpWidget(
      GetMaterialApp(
        home: const ComparisonScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify empty state is displayed
    expect(find.text('Add products to compare'), findsOneWidget);
    expect(find.text('Browse Products'), findsOneWidget);
  });
}
