import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Current active slide index
  var currentPage = 0.obs;

  // Total pages
  final int totalPages = 3;

  void updatePage(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    } else {
      completeOnboarding();
    }
  }

  void completeOnboarding() {
    // Navigate directly to login screen, replacing the onboarding route
    Get.offAllNamed('/login');
  }
}
