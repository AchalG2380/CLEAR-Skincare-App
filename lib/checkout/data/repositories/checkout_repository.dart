import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/repositories/orders_repository.dart';
import '../../../core/api_config.dart';

class CheckoutRepository {
  final String baseUrl = ApiConfig.baseUrl;

  static final List<AddressModel> mockAddresses = [
    AddressModel(
      id: 'addr_001',
      name: 'Jane Doe',
      phone: '+1 555-0199',
      street: '123 Glow Avenue, Suite 101',
      city: 'New York',
      pincode: '10001',
      state: 'NY',
    ),
    AddressModel(
      id: 'addr_002',
      name: 'Jane Doe Office',
      phone: '+1 555-0188',
      street: '456 Radiance Blvd, Floor 4',
      city: 'San Francisco',
      pincode: '94105',
      state: 'CA',
    ),
  ];

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return mockAddresses;
    }
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final newId = address.id.isEmpty
        ? 'addr_${DateTime.now().millisecondsSinceEpoch}'
        : address.id;
    final created = AddressModel(
      id: newId,
      name: address.name,
      phone: address.phone,
      street: address.street,
      city: address.city,
      pincode: address.pincode,
      state: address.state,
    );
    mockAddresses.add(created);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/address'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AddressModel.fromJson(data);
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return created;
    }
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    final idx = mockAddresses.indexWhere((e) => e.id == address.id);
    if (idx != -1) {
      mockAddresses[idx] = address;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/address/${address.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(address.toJson()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AddressModel.fromJson(data);
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return address;
    }
  }

  Future<bool> deleteAddress(String id) async {
    mockAddresses.removeWhere((e) => e.id == id);

    try {
      final response = await http.delete(Uri.parse('$baseUrl/address/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return true;
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[now.month - 1];
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    return '$month ${now.day}, ${now.year}, $hour:$minute $ampm';
  }

  Future<Map<String, dynamic>> placeOrder({
    required AddressModel address,
    required String paymentMethod,
    required List<dynamic> items,
    required double total,
    double subtotal = 0.0,
    double discount = 0.0,
    double deliveryFee = 0.0,
    String? couponCode,
  }) async {
    final String orderId =
        'CLR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    // Construct and store mock order representation in shared static history
    final orderItems = items
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final formattedDate = _formatCurrentDate();

    final newOrder = OrderModel(
      id: orderId,
      date: formattedDate,
      total: total,
      status: 'Processing',
      items: orderItems,
      address: address,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      trackingStages: [
        TrackingStageModel(
          title: 'Order Placed',
          timestamp: formattedDate,
          isCompleted: true,
        ),
        TrackingStageModel(
          title: 'Order Confirmed',
          timestamp: formattedDate,
          isCompleted: true,
        ),
        TrackingStageModel(
          title: 'Shipped',
          timestamp: null,
          isCompleted: false,
        ),
        TrackingStageModel(
          title: 'Out for Delivery',
          timestamp: null,
          isCompleted: false,
        ),
        TrackingStageModel(
          title: 'Delivered',
          timestamp: null,
          isCompleted: false,
        ),
      ],
    );

    OrdersRepository.mockOrders.add(newOrder);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'addressId': address.id,
          'paymentMethod': paymentMethod,
          'items': items,
          'total': total,
          if (couponCode != null) 'couponCode': couponCode,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock fallback order success
      return {
        'status': 'success',
        'orderId': orderId,
        'message': 'Order placed successfully',
      };
    }
  }
}
