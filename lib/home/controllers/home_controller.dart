import 'package:get/get.dart';
import '../../core/controllers/base_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../data/models/home_response_model.dart';
import '../data/repositories/home_repository.dart';

class HomeController extends BaseSkincareController {
  final HomeRepository _homeRepository = HomeRepository();

  // Observable home data
  final homeData = Rxn<HomeResponseModel>();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true; // Ensure starts as loading
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    final data = await runSafeApiCall(() async {
      // Simulate artificial loading delay
      await Future.delayed(const Duration(milliseconds: 1500));
      return _homeRepository.getHomeData();
    });

    if (data != null) {
      homeData.value = data;

      // Sync with global WishlistController
      final wishlistController = Get.find<WishlistController>();
      for (var p in data.bestSellers) {
        if (p.isWishlisted.value) {
          wishlistController.wishlistedIds.add(p.id);
        }
      }
      for (var p in data.newArrivals) {
        if (p.isWishlisted.value) {
          wishlistController.wishlistedIds.add(p.id);
        }
      }
    }
  }
}
