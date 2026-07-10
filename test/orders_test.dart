import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:clear/orders/controllers/orders_controller.dart';

void main() {
  setUp(() {
    // Clear GetX registry before each test
    Get.reset();
  });

  test('OrdersController loads orders and specific detail timelines', () async {
    // 1. Initialize controller
    final ordersController = Get.put(OrdersController());

    // 2. Load and verify orders history list (async mock call)
    await ordersController.fetchOrders();
    expect(ordersController.orders.isNotEmpty, true);
    
    // Verify first seeded order details
    final deliveredOrder = ordersController.orders.firstWhere((o) => o.id == 'CLR-720916-P1');
    expect(deliveredOrder.status, 'Delivered');
    expect(deliveredOrder.total, 38.00);
    expect(deliveredOrder.items.length, 2);

    // Verify second seeded order details
    final processingOrder = ordersController.orders.firstWhere((o) => o.id == 'CLR-720917-P2');
    expect(processingOrder.status, 'Processing');
    expect(processingOrder.total, 52.00);
    expect(processingOrder.items.length, 1);

    // 3. Load detail view specifically
    await ordersController.fetchOrderDetails('CLR-720917-P2');
    expect(ordersController.orderDetails.value, isNotNull);
    expect(ordersController.orderDetails.value?.id, 'CLR-720917-P2');
    
    // Verify stages: Order Placed/Confirmed must be done, Shipped/Delivered pending
    final stages = ordersController.orderDetails.value!.trackingStages;
    expect(stages.length, 5);
    expect(stages[0].isCompleted, true); // Order Placed
    expect(stages[1].isCompleted, true); // Order Confirmed
    expect(stages[2].isCompleted, false); // Shipped
    expect(stages[4].isCompleted, false); // Delivered
  });
}
