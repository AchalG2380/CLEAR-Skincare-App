import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../data/models/address_model.dart';
import '../data/repositories/checkout_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../core/controllers/rewards_controller.dart';
import '../../orders/data/models/order_model.dart';

class CheckoutController extends GetxController {
  final CheckoutRepository _repo = CheckoutRepository();

  // Observable state
  final addresses = <AddressModel>[].obs;
  var isLoadingAddresses = false.obs;
  var isSavingAddress = false.obs;
  var isPlacingOrder = false.obs;

  // Selected step options
  final selectedAddress = Rxn<AddressModel>();
  final selectedPaymentMethod =
      ''.obs; // e.g., 'Card', 'UPI', 'Cash on Delivery'

  // Dummy Card Fields
  final cardNumber = ''.obs;
  final cardExpiry = ''.obs;
  final cardCvv = ''.obs;

  // Cart/Summary info passed from Cart
  var subtotal = 0.0.obs;
  var discount = 0.0.obs;
  var pointsDiscount = 0.0.obs;
  var pointsConsumed = 0.obs;
  var deliveryFee = 0.0.obs;
  var tax = 0.0.obs;
  var total = 0.0.obs;
  final items = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      subtotal.value = (args['subtotal'] as num?)?.toDouble() ?? 0.0;
      discount.value = (args['discount'] as num?)?.toDouble() ?? 0.0;
      pointsDiscount.value = (args['pointsDiscount'] as num?)?.toDouble() ?? 0.0;
      pointsConsumed.value = (args['pointsConsumed'] as num?)?.toInt() ?? 0;
      deliveryFee.value = (args['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      total.value = (args['total'] as num?)?.toDouble() ?? 0.0;
      items.value = args['items'] as List<dynamic>? ?? [];
    }
    fetchAddresses();
    fetchCheckoutSummary();
    ever(selectedAddress, (_) => fetchCheckoutSummary());
  }

  Future<void> fetchCheckoutSummary() async {
    try {
      final summary = await _repo.getCheckoutSummary();
      subtotal.value = (summary['subtotal'] as num?)?.toDouble() ?? 0.0;
      discount.value = (summary['discount'] as num?)?.toDouble() ?? 0.0;
      deliveryFee.value = (summary['shipping'] as num?)?.toDouble() ?? (summary['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      tax.value = (summary['tax'] as num?)?.toDouble() ?? 0.0;
      total.value = (summary['total'] as num?)?.toDouble() ?? 0.0;
    } catch (_) {}
  }

  Future<void> fetchAddresses() async {
    try {
      isLoadingAddresses.value = true;
      final loaded = await _repo.getAddresses();
      addresses.assignAll(loaded);
      if (loaded.isNotEmpty && selectedAddress.value == null) {
        selectedAddress.value = loaded.first; // Auto-select first address
      }
    } catch (_) {
      // Mock repository handles error and returns default list
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  Future<void> addAddress({
    required String name,
    required String phone,
    required String street,
    required String city,
    required String pincode,
    required String state,
  }) async {
    try {
      isSavingAddress.value = true;
      final newAddr = AddressModel(
        id: '',
        name: name,
        phone: phone,
        street: street,
        city: city,
        pincode: pincode,
        state: state,
      );
      final saved = await _repo.addAddress(newAddr);
      addresses.add(saved);
      selectedAddress.value = saved; // Auto-select newly added address
      Get.snackbar(
        'Success',
        'Address added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.backgroundColor.withValues(alpha: 0.94),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add address.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingAddress.value = false;
    }
  }

  Future<void> placeOrder() async {
    final address = selectedAddress.value;
    final payment = selectedPaymentMethod.value;

    if (address == null) {
      Get.snackbar(
        'Error',
        'Please select a delivery address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (payment.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isPlacingOrder.value = true;

      final OrderModel order = await _repo.placeOrder(
        addressId: address.id,
      );

      final orderId = order.id;

      // Update reward points balance: deduct consumed, add earned
      final rewardsController = Get.find<RewardsController>();
      final earned = total.value.floor();
      await rewardsController.applyOrderResult(
        redeemed: pointsConsumed.value,
        earned: earned,
      );

      // Reset points toggle state in CartController
      Get.find<CartController>().isPointsRedeemed.value = false;

      // Clear the Cart globally and on the server
      await Get.find<CartController>().clearCartOnServer();

      // Go to Success page
      Get.offAllNamed('/checkout-success', arguments: orderId);
    } catch (e) {
      Get.snackbar(
        'Order Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.backgroundColor.withValues(alpha: 0.94),
        colorText: Colors.white,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    try {
      isSavingAddress.value = true;
      final updated = await _repo.updateAddress(address);
      final idx = addresses.indexWhere((e) => e.id == address.id);
      if (idx != -1) {
        addresses[idx] = updated;
      }
      if (selectedAddress.value?.id == address.id) {
        selectedAddress.value = updated;
      }
      Get.snackbar(
        'Success',
        'Address updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.backgroundColor.withValues(alpha: 0.94),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update address.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingAddress.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _repo.deleteAddress(id);
      addresses.removeWhere((e) => e.id == id);
      if (selectedAddress.value?.id == id) {
        selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
      }
      Get.snackbar(
        'Success',
        'Address deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.backgroundColor.withValues(alpha: 0.94),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete address.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
