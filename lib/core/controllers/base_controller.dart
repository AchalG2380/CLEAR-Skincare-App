import 'package:get/get.dart';

class BaseSkincareController extends GetxController {
  // Reusable observable states
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  /// Runs an asynchronous API call safely, managing [isLoading], [hasError], and [errorMessage] automatically.
  Future<T?> runSafeApiCall<T>(
    Future<T> Function() apiCall, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      hasError.value = false;
      errorMessage.value = '';

      final result = await apiCall();
      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }
}
