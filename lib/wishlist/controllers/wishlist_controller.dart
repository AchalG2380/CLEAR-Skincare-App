import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../data/repositories/wishlist_repository.dart';

class WishlistController extends GetxController {
  final WishlistRepository _repo = WishlistRepository();

  // Observable state
  final wishlistItems = <ProductModel>[].obs;
  final wishlistedIds = <String>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      isLoading.value = true;
      final items = await _repo.getWishlist();
      wishlistItems.assignAll(items);
      // Synchronize sets
      wishlistedIds.assignAll(items.map((e) => e.id));
    } catch (_) {
      // Keep existing list or fail silently
    } finally {
      isLoading.value = false;
    }
  }

  bool isWishlisted(String productId) {
    return wishlistedIds.contains(productId);
  }

  // Centrally handles adding/removing items from wishlist with optimistic UI updates
  Future<void> toggleWishlist(ProductModel product) async {
    final productId = product.id;
    if (isWishlisted(productId)) {
      // Optimistic remove
      wishlistedIds.remove(productId);
      final index = wishlistItems.indexWhere((p) => p.id == productId);
      ProductModel? removedProduct;
      if (index != -1) {
        removedProduct = wishlistItems.removeAt(index);
      }

      try {
        await _repo.removeFromWishlist(productId);
        _showSnackbar('Removed', '${product.name} removed from Wishlist');
      } catch (e) {
        // Rollback on error
        wishlistedIds.add(productId);
        if (removedProduct != null && index != -1) {
          wishlistItems.insert(index, removedProduct);
        }
        _showSnackbar('Error', 'Failed to remove ${product.name}');
      }
    } else {
      // Optimistic add
      wishlistedIds.add(productId);
      if (!wishlistItems.any((p) => p.id == productId)) {
        wishlistItems.add(product);
      }

      try {
        await _repo.addToWishlist(productId);
        _showSnackbar('Wishlisted', '${product.name} added to Wishlist');
      } catch (e) {
        // Rollback on error
        wishlistedIds.remove(productId);
        wishlistItems.removeWhere((p) => p.id == productId);
        _showSnackbar('Error', 'Failed to add ${product.name}');
      }
    }
  }

  // Removes item from wishlist and adds to cart
  Future<void> moveToCart(ProductModel product) async {
    final productId = product.id;
    
    // 1. Optimistic remove from wishlist
    wishlistedIds.remove(productId);
    final index = wishlistItems.indexWhere((p) => p.id == productId);
    ProductModel? removedProduct;
    if (index != -1) {
      removedProduct = wishlistItems.removeAt(index);
    }

    try {
      // 2. Add to Cart (which handles its own background API POST call)
      await Get.find<CartController>().addToCart(product);

      // Perform delete request in background
      await _repo.removeFromWishlist(productId);
    } catch (e) {
      // Rollback
      wishlistedIds.add(productId);
      if (removedProduct != null && index != -1) {
        wishlistItems.insert(index, removedProduct);
      }
      _showSnackbar('Error', 'Failed to process move operation');
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color.fromARGB(240, 19, 5, 56),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }
}
