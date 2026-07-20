import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clear/core/controllers/recently_viewed_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  test('RecentlyViewedController tracks, de-duplicates, and caps items', () async {
    final controller = Get.put(RecentlyViewedController());
    controller.isTesting = true;
    await controller.loadRecentlyViewed();

    expect(controller.recentlyViewedIds.length, 0);

    // Record views
    await controller.recordView('p1');
    await controller.recordView('p2');
    await controller.recordView('p3');

    // Most recent should be at the front (index 0)
    expect(controller.recentlyViewedIds.length, 3);
    expect(controller.recentlyViewedIds[0], 'p3');
    expect(controller.recentlyViewedIds[2], 'p1');

    // De-duplicate: view 'p1' again (moves to front)
    await controller.recordView('p1');
    expect(controller.recentlyViewedIds.length, 3);
    expect(controller.recentlyViewedIds[0], 'p1');
    expect(controller.recentlyViewedIds[1], 'p3');
    expect(controller.recentlyViewedIds[2], 'p2');

    // Cap test: add up to 20 items, should keep only most recent 15
    for (int i = 10; i < 30; i++) {
      await controller.recordView('p$i');
    }

    expect(controller.recentlyViewedIds.length, 15);
    expect(controller.recentlyViewedIds[0], 'p29'); // Latest added
    expect(controller.recentlyViewedIds.contains('p1'), false); // Oldest dropped

    // Clear history
    await controller.clearHistory();
    expect(controller.recentlyViewedIds.length, 0);
  });
}
