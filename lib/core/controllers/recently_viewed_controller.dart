import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/data/models/product_model.dart';
import '../../product_details/data/repositories/product_details_repository.dart';

class RecentlyViewedController extends GetxController {
  static const String _keyRecentlyViewed = 'recently_viewed_ids';

  final recentlyViewedIds = <String>[].obs;
  final recentlyViewedProducts = <ProductModel>[].obs;
  var isLoading = false.obs;
  bool isTesting = false;

  @override
  void onInit() {
    super.onInit();
    loadRecentlyViewed();
  }

  Future<void> loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_keyRecentlyViewed) ?? [];
      recentlyViewedIds.assignAll(ids);
      await hydrateProducts();
    } catch (_) {
      recentlyViewedIds.clear();
      recentlyViewedProducts.clear();
    }
  }

  Future<void> recordView(String productId) async {
    if (productId.trim().isEmpty) return;

    // 1. Remove if already exists (de-duplicate)
    recentlyViewedIds.remove(productId);

    // 2. Insert at index 0 (front of list)
    recentlyViewedIds.insert(0, productId);

    // 3. Cap at 15 items
    if (recentlyViewedIds.length > 15) {
      recentlyViewedIds.removeLast();
    }

    try {
      // 4. Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyRecentlyViewed, recentlyViewedIds);
      
      // 5. Re-hydrate product models for display
      await hydrateProducts();
    } catch (_) {}
  }

  Future<void> hydrateProducts() async {
    final ids = List<String>.from(recentlyViewedIds);
    if (ids.isEmpty) {
      recentlyViewedProducts.clear();
      return;
    }

    try {
      isLoading.value = true;

      if (isTesting) {
        final mockProducts = ids.map((id) => ProductModel(
          id: id,
          name: 'Product $id',
          imageUrl: 'assets/images/cream.webp',
          price: 29.99,
          rating: 4.5,
          isWishlisted: false,
        )).toList();
        recentlyViewedProducts.assignAll(mockProducts);
        return;
      }

      final ProductDetailsRepository detailsRepo = ProductDetailsRepository();

      // Fetch all details in parallel
      final results = await Future.wait(
        ids.map((id) async {
          try {
            final details = await detailsRepo.getProductDetails(id);
            return details.toProductModel();
          } catch (_) {
            return null;
          }
        }),
      );

      // Filter out any null products (e.g. products removed from catalog)
      final validProducts = results.whereType<ProductModel>().toList();
      recentlyViewedProducts.assignAll(validProducts);
    } catch (_) {
      // Fail silently
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearHistory() async {
    try {
      recentlyViewedIds.clear();
      recentlyViewedProducts.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRecentlyViewed);
    } catch (_) {}
  }
}
