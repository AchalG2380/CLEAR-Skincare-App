import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:clear/cart/controllers/cart_controller.dart';
import 'package:clear/checkout/controllers/checkout_controller.dart';

void main() {
  setUp(() {
    // Clear GetX instance registry before each test
    Get.reset();
  });

  testWidgets('CheckoutController parses arguments and manages selections', (WidgetTester tester) async {
    // 1. Register global dependencies
    Get.put(CartController());

    // Mock navigation arguments
    final Map<String, dynamic> mockArgs = {
      'subtotal': 50.0,
      'discount': 10.0,
      'deliveryFee': 0.0,
      'total': 40.0,
      'items': [
        {
          'product': {
            'id': 's1',
            'name': 'Vitamin C Radiance Serum',
            'imageUrl': 'https://images.unsplash.com',
            'price': 29.99,
            'rating': 4.8,
            'isWishlisted': true,
            'category': 'cat_serum',
            'concern': 'Dark Spots',
          },
          'quantity': 1,
        }
      ],
    };

    // Pump a GetMaterialApp to supply the overlays for Get.snackbar
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/checkout',
        getPages: [
          GetPage(
            name: '/checkout',
            page: () => const SizedBox.shrink(),
            arguments: mockArgs,
          ),
        ],
      ),
    );

    // Set arguments in Get routing environment explicitly for synchronous access
    Get.routing.args = mockArgs;

    // 2. Initialize controller
    final checkoutController = Get.put(CheckoutController());

    // 3. Assert initial state parsing
    expect(checkoutController.subtotal.value, 50.0);
    expect(checkoutController.discount.value, 10.0);
    expect(checkoutController.deliveryFee.value, 0.0);
    expect(checkoutController.total.value, 40.0);
    expect(checkoutController.items.length, 1);

    // 4. Assert address loading (triggered in onInit)
    await checkoutController.fetchAddresses();
    expect(checkoutController.addresses.isNotEmpty, true);
    expect(checkoutController.selectedAddress.value, isNotNull);

    // 5. Test add address
    final initialLength = checkoutController.addresses.length;
    await checkoutController.addAddress(
      name: 'Test Name',
      phone: '1234567890',
      street: '456 Test Street',
      city: 'Test City',
      pincode: '999999',
      state: 'TS',
    );
    await tester.pump(); // Process visual overlay state

    expect(checkoutController.addresses.length, initialLength + 1);
    expect(checkoutController.selectedAddress.value?.name, 'Test Name');

    // 6. Test payment selection
    expect(checkoutController.selectedPaymentMethod.value, '');
    checkoutController.selectedPaymentMethod.value = 'Card';
    expect(checkoutController.selectedPaymentMethod.value, 'Card');

    // Pump to let the snackbar animation and timer complete (clean up pending timers)
    await tester.pump(const Duration(seconds: 5));
  });
}
