import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:clear/profile/controllers/profile_controller.dart';
import 'package:clear/checkout/controllers/checkout_controller.dart';
import 'package:clear/checkout/data/models/address_model.dart';
import 'package:clear/cart/controllers/cart_controller.dart';
import 'package:clear/wishlist/controllers/wishlist_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('ProfileController fetches, edits details and validates password rules', (WidgetTester tester) async {
    // Register global dependencies
    Get.put(CartController());
    Get.put(WishlistController());

    // Pump GetMaterialApp to supply overlay context
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    final profileController = Get.put(ProfileController());

    // 1. Fetch initial profile
    await profileController.fetchProfile();
    expect(profileController.profile.value, isNotNull);
    expect(profileController.profile.value?.name, 'Jane Doe');
    expect(profileController.profile.value?.email, 'jane.doe@example.com');

    // 2. Perform Profile edit validation
    // Empty inputs
    var success = await profileController.updateProfile(name: '', email: '', phone: '');
    expect(success, false);
    await tester.pump(const Duration(seconds: 5));

    // Invalid email
    success = await profileController.updateProfile(name: 'Updated Jane', email: 'invalid_email', phone: '123456');
    expect(success, false);
    await tester.pump(const Duration(seconds: 5));

    // Valid update
    success = await profileController.updateProfile(name: 'Updated Jane', email: 'updated.jane@example.com', phone: '+1 555-0199');
    expect(success, true);
    await tester.pump(const Duration(seconds: 5));
    expect(profileController.profile.value?.name, 'Updated Jane');
    expect(profileController.profile.value?.email, 'updated.jane@example.com');

    // 3. Change password validation
    // Password too short
    success = await profileController.changePassword(currentPassword: '123', newPassword: 'abc', confirmPassword: 'abc');
    expect(success, false);
    await tester.pump(const Duration(seconds: 5));

    // Mismatched confirmation
    success = await profileController.changePassword(currentPassword: 'password123', newPassword: 'newsecurepass', confirmPassword: 'differentpass');
    expect(success, false);
    await tester.pump(const Duration(seconds: 5));

    // Correct change
    success = await profileController.changePassword(currentPassword: 'password123', newPassword: 'newsecurepass', confirmPassword: 'newsecurepass');
    expect(success, true);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('CheckoutController supports updating and deleting saved addresses', (WidgetTester tester) async {
    // Register global dependencies
    Get.put(CartController());
    Get.put(WishlistController());

    // Pump GetMaterialApp
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    final checkoutController = Get.put(CheckoutController());

    // Populate initial addresses list
    await checkoutController.fetchAddresses();
    expect(checkoutController.addresses.length, 2);

    final originalAddress = checkoutController.addresses.first;
    expect(originalAddress.city, 'New York');

    // Update existing address
    final updatedAddress = AddressModel(
      id: originalAddress.id,
      name: 'Jane Updated Name',
      phone: originalAddress.phone,
      street: '456 Updated St',
      city: 'Updated York',
      pincode: '20002',
      state: 'NY',
    );
    await checkoutController.updateAddress(updatedAddress);
    await tester.pump(const Duration(seconds: 5));
    
    // Verify changes are reactively updated
    final foundIndex = checkoutController.addresses.indexWhere((e) => e.id == originalAddress.id);
    expect(checkoutController.addresses[foundIndex].name, 'Jane Updated Name');
    expect(checkoutController.addresses[foundIndex].city, 'Updated York');

    // Delete address
    await checkoutController.deleteAddress(originalAddress.id);
    await tester.pump(const Duration(seconds: 5));
    expect(checkoutController.addresses.length, 1);
    expect(checkoutController.addresses.any((e) => e.id == originalAddress.id), false);
  });
}
