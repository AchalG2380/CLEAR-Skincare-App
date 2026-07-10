import 'package:get/get.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../data/models/product_details_model.dart';
import '../data/repositories/product_details_repository.dart';

class ProductDetailsController extends GetxController {
  final ProductDetailsRepository _repo = ProductDetailsRepository();

  // Observable state
  final productDetails = Rxn<ProductDetailsModel>();
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // UI state
  var selectedImageIndex = 0.obs;
  var quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final String? productId = Get.arguments as String?;
    if (productId != null && productId.isNotEmpty) {
      fetchProductDetails(productId);
    } else {
      hasError.value = true;
      errorMessage.value = 'Product ID not specified.';
      isLoading.value = false;
    }
  }

  Future<void> fetchProductDetails(String productId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final details = await _repo.getProductDetails(productId);
      productDetails.value = details;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void updateImageIndex(int index) {
    selectedImageIndex.value = index;
  }

  // Action methods
  void addToCart() {
    final details = productDetails.value;
    if (details == null) return;

    final baseProduct = details.toProductModel();
    Get.find<CartController>().addToCart(baseProduct, quantity.value);
  }

  void toggleWishlist() {
    final details = productDetails.value;
    if (details == null) return;

    final baseProduct = details.toProductModel();
    Get.find<WishlistController>().toggleWishlist(baseProduct);
  }
}
