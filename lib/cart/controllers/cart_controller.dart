import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:get/get.dart';
import '../../home/data/models/product_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/repositories/cart_repository.dart';
import '../../core/controllers/rewards_controller.dart';

class CartController extends GetxController {
  final CartRepository _repo = CartRepository();

  // Observable state
  final cartItems = <CartItemModel>[].obs;
  var isLoading = false.obs;
  var discount = 0.0.obs;
  var couponCode = ''.obs;
  final isPointsRedeemed = false.obs;

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

  double get pointsDiscount {
    if (!isPointsRedeemed.value) return 0.0;
    final rewardsController = Get.find<RewardsController>();
    final balance = rewardsController.pointsBalance.value;
    final potentialDiscount = balance / 100.0;
    final maxDiscount = subtotal * 0.5;
    return potentialDiscount > maxDiscount ? maxDiscount : potentialDiscount;
  }

  int get pointsConsumed {
    return (pointsDiscount * 100).round();
  }

  double get total {
    final finalPrice = subtotal - discount.value - pointsDiscount + deliveryFee;
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

      _debounceQuantityUpdate(item.cartItemId, item.quantity);
    } else {
      // New item, add to list optimistically with specified qty
      final newItem = CartItemModel(
        cartItemId: 'temp_${product.id}',
        product: product,
        quantity: qty,
      );
      cartItems.add(newItem);

      try {
        await _repo.addToCart(product.id, qty);
        _showSnackbar('Added to Cart', '${product.name} added to your Cart');
        await fetchCart();
      } catch (e) {
        // Rollback
        cartItems.removeWhere((item) => item.product.id == product.id);
        _showSnackbar('Error', 'Failed to add item to Cart');
      }
    }
  }

  // --- Update Quantity (Optimistic & Debounced) ---
  void updateQuantity(String idOrCartItemId, int delta) {
    var index = cartItems.indexWhere((item) => item.cartItemId == idOrCartItemId);
    if (index == -1) {
      index = cartItems.indexWhere((item) => item.product.id == idOrCartItemId);
    }
    if (index == -1) return;

    final item = cartItems[index];
    final originalQty = item.quantity;
    final productId = item.product.id;
    final cartItemId = item.cartItemId;

    // Cache original quantity if not already cached during this tap sequence
    if (!_originalQuantities.containsKey(productId)) {
      _originalQuantities[productId] = originalQty;
    }

    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      // Remove from cart optimistically
      removeFromCart(cartItemId);
    } else {
      // Update locally instantly
      item.quantity = newQty;
      cartItems[index] = item; // Trigger Obx updates

      _debounceQuantityUpdate(cartItemId, newQty);
    }
  }

  // --- Debounce mechanism ---
  void _debounceQuantityUpdate(String cartItemId, int newQty) {
    // Cancel any pending timer for this product
    _debounceTimers[cartItemId]?.cancel();

    // Schedule the network call after 500ms of inactivity
    _debounceTimers[cartItemId] = Timer(
      const Duration(milliseconds: 500),
      () async {
        try {
          await _repo.updateQuantity(cartItemId, newQty);
          // Successfully updated, clean up cache
          final index = cartItems.indexWhere((item) => item.cartItemId == cartItemId);
          if (index != -1) {
            _originalQuantities.remove(cartItems[index].product.id);
          }
        } catch (e) {
          // Rollback to original value
          final index = cartItems.indexWhere((item) => item.cartItemId == cartItemId);
          if (index != -1) {
            final productId = cartItems[index].product.id;
            final cachedQty = _originalQuantities[productId];
            if (cachedQty != null) {
              cartItems[index].quantity = cachedQty;
              cartItems.refresh();
              _originalQuantities.remove(productId);
            }
            _showSnackbar('Error', 'Failed to update quantity');
          }
        } finally {
          _debounceTimers.remove(cartItemId);
        }
      },
    );
  }

  // --- Remove from Cart ---
  Future<void> removeFromCart(String idOrCartItemId) async {
    var index = cartItems.indexWhere((item) => item.cartItemId == idOrCartItemId);
    if (index == -1) {
      index = cartItems.indexWhere((item) => item.product.id == idOrCartItemId);
    }
    if (index == -1) return;

    final removedItem = cartItems.removeAt(index);

    try {
      await _repo.removeFromCart(removedItem.cartItemId);
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

  Future<void> clearCartOnServer() async {
    final items = List<CartItemModel>.from(cartItems);
    clearCart();
    if (items.isNotEmpty) {
      try {
        await Future.wait(items.map((item) => _repo.removeFromCart(item.cartItemId)));
      } catch (_) {}
    }
  }
}
