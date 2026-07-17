import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clear/core/controllers/rewards_controller.dart';
import 'package:clear/cart/controllers/cart_controller.dart';
import 'package:clear/cart/data/models/cart_item_model.dart';
import 'package:clear/home/data/models/product_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  test('RewardsController initializes balance and performs atomic updates', () async {
    SharedPreferences.setMockInitialValues({'reward_points': 150});
    final controller = Get.put(RewardsController());

    // Initially balance should read from SharedPreferences
    // Wait for controller initialization
    await Future.delayed(Duration.zero);
    expect(controller.pointsBalance.value, 150);

    // Perform atomic transaction: deduct 50, earn 20
    await controller.applyOrderResult(redeemed: 50, earned: 20);
    expect(controller.pointsBalance.value, 120);

    // Verify written value in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('reward_points'), 120);
  });

  test('CartController computes rewards discount and caps at 50% subtotal', () {
    final rewards = Get.put(RewardsController());
    rewards.pointsBalance.value = 300; // $3.00 potential discount

    final cart = Get.put(CartController());
    
    // Add item to cart
    final product = ProductModel(
      id: 'p1',
      name: 'Sample Product',
      imageUrl: '',
      price: 10.0, // Subtotal = $10.00
      rating: 4.5,
      isWishlisted: false,
    );
    cart.cartItems.add(CartItemModel(
      cartItemId: 'item_1',
      product: product,
      quantity: 1,
    ));

    // Initially points not redeemed
    expect(cart.pointsDiscount, 0.0);
    expect(cart.total, 10.0);

    // Toggle points redemption
    cart.isPointsRedeemed.value = true;
    
    // Potential discount: $3.00 (from 300 points)
    // 50% cap of subtotal $10.00: $5.00
    // Should apply full $3.00 discount
    expect(cart.pointsDiscount, 3.0);
    expect(cart.pointsConsumed, 300);
    expect(cart.total, 7.0); // 10.0 - 3.0

    // Raise points balance to exceed 50% cap
    rewards.pointsBalance.value = 800; // $8.00 potential discount
    
    // Should cap discount at $5.00 (50% of $10.00)
    expect(cart.pointsDiscount, 5.0);
    expect(cart.pointsConsumed, 500);
    expect(cart.total, 5.0); // 10.0 - 5.0
  });
}
