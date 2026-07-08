import 'package:get/get.dart';
import '../data/models/home_response_model.dart';
import '../data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepository = HomeRepository();

  // Observable states
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var homeData = Rxn<HomeResponseModel>();

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Introduce a brief artificial delay to let shimmer skeleton be visible (simulating real load)
      await Future.delayed(const Duration(milliseconds: 1500));

      final data = await _homeRepository.getHomeData();
      homeData.value = data;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    }
  }
}
