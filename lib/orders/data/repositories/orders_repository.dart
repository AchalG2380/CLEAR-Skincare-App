import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/order_model.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../checkout/data/models/address_model.dart';
import '../../../home/data/models/product_model.dart';

class OrdersRepository {
  final String baseUrl = 'https://your-api-base-url.com/api';

  // Seed default past orders in static memory so they persist during session
  static final List<OrderModel> mockOrders = [
    OrderModel(
      id: 'CLR-720916-P1',
      date: 'Jul 9, 2026, 11:30 AM',
      total: 38.00,
      status: 'Delivered',
      items: [
        CartItemModel(
          product: ProductModel(
            id: 'c2',
            name: 'Micellar Cleansing Water',
            imageUrl: 'assets/images/moisturrizer2.webp',
            price: 14.00,
            rating: 4.3,
            isWishlisted: false,
            category: 'cat_cleanser',
            concern: 'Dry & Flaky Skin',
          ),
          quantity: 1,
        ),
        CartItemModel(
          product: ProductModel(
            id: 'm1',
            name: 'Barrier Recovery Cream',
            imageUrl: 'assets/images/cream.webp',
            price: 24.00,
            rating: 4.6,
            isWishlisted: false,
            category: 'cat_moisturizer',
            concern: 'Dry & Flaky Skin',
          ),
          quantity: 1,
        ),
      ],
      address: AddressModel(
        id: 'addr_001',
        name: 'Jane Doe',
        phone: '+1 555-0199',
        street: '123 Glow Avenue, Suite 101',
        city: 'New York',
        pincode: '10001',
        state: 'NY',
      ),
      paymentMethod: 'Card',
      subtotal: 38.00,
      discount: 0.0,
      deliveryFee: 0.0,
      trackingStages: [
        TrackingStageModel(title: 'Order Placed', timestamp: 'Jul 9, 11:30 AM', isCompleted: true),
        TrackingStageModel(title: 'Order Confirmed', timestamp: 'Jul 9, 11:45 AM', isCompleted: true),
        TrackingStageModel(title: 'Shipped', timestamp: 'Jul 9, 3:00 PM', isCompleted: true),
        TrackingStageModel(title: 'Out for Delivery', timestamp: 'Jul 10, 9:00 AM', isCompleted: true),
        TrackingStageModel(title: 'Delivered', timestamp: 'Jul 10, 11:15 AM', isCompleted: true),
      ],
    ),
    OrderModel(
      id: 'CLR-720917-P2',
      date: 'Jul 10, 2026, 8:00 AM',
      total: 52.00,
      status: 'Processing',
      items: [
        CartItemModel(
          product: ProductModel(
            id: 's3',
            name: 'HA Plumping Serum',
            imageUrl: 'assets/images/moisturrizer2.webp',
            price: 26.00,
            rating: 4.4,
            isWishlisted: false,
            category: 'cat_serum',
            concern: 'Dry & Flaky Skin',
          ),
          quantity: 2,
        ),
      ],
      address: AddressModel(
        id: 'addr_002',
        name: 'Jane Doe Office',
        phone: '+1 555-0188',
        street: '456 Radiance Blvd, Floor 4',
        city: 'San Francisco',
        pincode: '94105',
        state: 'CA',
      ),
      paymentMethod: 'UPI',
      subtotal: 52.00,
      discount: 0.0,
      deliveryFee: 0.0,
      trackingStages: [
        TrackingStageModel(title: 'Order Placed', timestamp: 'Jul 10, 8:00 AM', isCompleted: true),
        TrackingStageModel(title: 'Order Confirmed', timestamp: 'Jul 10, 8:30 AM', isCompleted: true),
        TrackingStageModel(title: 'Shipped', timestamp: null, isCompleted: false),
        TrackingStageModel(title: 'Out for Delivery', timestamp: null, isCompleted: false),
        TrackingStageModel(title: 'Delivered', timestamp: null, isCompleted: false),
      ],
    ),
  ];

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock fallback: return reverse chronological order history
      return mockOrders.reversed.toList();
    }
  }

  Future<OrderModel> getOrderDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return OrderModel.fromJson(data);
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock fallback
      final index = mockOrders.indexWhere((e) => e.id == id);
      if (index != -1) {
        return mockOrders[index];
      }
      throw Exception('Order not found.');
    }
  }
}
