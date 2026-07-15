import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:get/get.dart';
import '../../home/data/models/product_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _repo = CartRepository();

  // Observable state
  final cartItems = <CartItemModel>[].obs;
  var isLoading = false.obs;
  var discount = 0.0.obs;
  var couponCode = ''.obs;

  // Track original quantities for rollbacks on API failures
  final Map<String, int> _originalQuantities = {};

  // Track debounce timers per product ID
  final Map<String, Timer> _debounceTimers = {};

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  @override
  void onClose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.onClose();
  }

  // --- Summary getters ---
  int get totalCartItems =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => cartItems.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double get deliveryFee {
    if (subtotal == 0.0 || subtotal >= 50.0) {
      return 0.0;
    }
    return 5.0; // Flat fee
  }

  double get total {
    final finalPrice = subtotal - discount.value + deliveryFee;
    return finalPrice < 0.0 ? 0.0 : finalPrice;
  }

  // --- Fetch Cart ---
  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      discount.value = 0.0;
      couponCode.value = '';
      final items = await _repo.getCart();
      cartItems.assignAll(items);
    } catch (_) {
      // Keep existing list or fail silently
    } finally {
      isLoading.value = false;
    }
  }

  int getProductQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return 0;
    return cartItems[index].quantity;
  }

  // --- Add to Cart ---
  Future<void> addToCart(ProductModel product, [int qty = 1]) async {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // Item already in cart, increment quantity by the specified qty
      final item = cartItems[index];
      _originalQuantities[product.id] = item.quantity;
      item.quantity += qty;
      cartItems[index] = item; // Trigger update

      _debounceQuantityUpdate(product.id, item.quantity);
    } else {
      // New item, add to list optimistically with specified qty
      final newItem = CartItemModel(product: product, quantity: qty);
      cartItems.add(newItem);

      try {
        await _repo.addToCart(product.id, qty);
        _showSnackbar('Added to Cart', '${product.name} added to your Cart');
      } catch (e) {
        // Rollback
        cartItems.removeWhere((item) => item.product.id == product.id);
        _showSnackbar('Error', 'Failed to add item to Cart');
      }
    }
  }

  // --- Update Quantity (Optimistic & Debounced) ---
  void updateQuantity(String productId, int delta) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final item = cartItems[index];
    final originalQty = item.quantity;

    // Cache original quantity if not already cached during this tap sequence
    if (!_originalQuantities.containsKey(productId)) {
      _originalQuantities[productId] = originalQty;
    }

    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      // Remove from cart optimistically
      removeFromCart(productId);
    } else {
      // Update locally instantly
      item.quantity = newQty;
      cartItems[index] = item; // Trigger Obx updates

      _debounceQuantityUpdate(productId, newQty);
    }
  }

  // --- Debounce mechanism ---
  void _debounceQuantityUpdate(String productId, int newQty) {
    // Cancel any pending timer for this product
    _debounceTimers[productId]?.cancel();

    // Schedule the network call after 500ms of inactivity
    _debounceTimers[productId] = Timer(
      const Duration(milliseconds: 500),
      () async {
        try {
          await _repo.updateQuantity(productId, newQty);
          // Successfully updated, clean up cache
          _originalQuantities.remove(productId);
        } catch (e) {
          // Rollback to original value
          final cachedQty = _originalQuantities[productId];
          if (cachedQty != null) {
            final index = cartItems.indexWhere(
              (item) => item.product.id == productId,
            );
            if (index != -1) {
              cartItems[index].quantity = cachedQty;
              cartItems.refresh();
            }
            _originalQuantities.remove(productId);
            _showSnackbar('Error', 'Failed to update quantity');
          }
        } finally {
          _debounceTimers.remove(productId);
        }
      },
    );
  }

  // --- Remove from Cart ---
  Future<void> removeFromCart(String productId) async {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    final removedItem = cartItems.removeAt(index);

    try {
      await _repo.removeFromCart(productId);
      _showSnackbar('Removed', '${removedItem.product.name} removed from Cart');
    } catch (e) {
      // Rollback
      cartItems.insert(index, removedItem);
      _showSnackbar('Error', 'Failed to remove ${removedItem.product.name}');
    }
  }

  // --- Apply Coupon ---
  Future<void> applyCoupon(String code) async {
    if (code.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter a coupon code');
      return;
    }

    try {
      final discountVal = await _repo.applyCoupon(code);
      discount.value = discountVal;
      couponCode.value = code.toUpperCase();
      _showSnackbar('Success', 'Coupon code applied successfully!');
    } catch (e) {
      discount.value = 0.0;
      couponCode.value = '';
      _showSnackbar(
        'Invalid Coupon',
        e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.backgroundColor.withValues(alpha: 0.94),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void clearCart() {
    cartItems.clear();
    discount.value = 0.0;
    couponCode.value = '';
    _originalQuantities.clear();
  }
}
