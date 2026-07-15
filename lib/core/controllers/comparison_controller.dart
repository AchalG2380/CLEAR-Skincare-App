import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_colors.dart';

class ComparisonController extends GetxController {
  // Reactive list containing compared product IDs
  final comparedIds = <String>[].obs;

  bool isCompared(String id) => comparedIds.contains(id);

  void toggleCompare(String id) {
    if (comparedIds.contains(id)) {
      comparedIds.remove(id);
      
      // Auto close comparison page if we drop to 0 items and are currently viewing it
      if (comparedIds.isEmpty && Get.currentRoute == '/product-comparison') {
        Get.back();
      }
    } else {
      if (comparedIds.length >= 3) {
        Get.snackbar(
          'Comparison Limit',
          'You can compare up to 3 products — remove one first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.surface.withValues(alpha: 0.95),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        comparedIds.add(id);
      }
    }
  }

  void clearComparison() {
    comparedIds.clear();
    if (Get.currentRoute == '/product-comparison') {
      Get.back();
    }
  }
}
