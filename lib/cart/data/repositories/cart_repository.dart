import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../home/data/models/product_model.dart';
import '../models/cart_item_model.dart';
import '../../../core/api_config.dart';

class CartRepository {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => CartItemModel.fromJson(e)).toList();
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock cart data containing default products
      return [
        CartItemModel(
          product: ProductModel(
            id: 's1',
            name: 'Vitamin C Radiance Serum',
            imageUrl: 'assets/images/Serum.jpg',
            price: 29.99,
            rating: 4.8,
            isWishlisted: true,
            category: 'cat_serum',
            concern: 'Dark Spots',
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
          quantity: 2,
        ),
      ];
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (_) {
      // Offline fallback success
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': quantity}),
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (_) {
      // Offline fallback success
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$productId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (_) {
      // Offline fallback success
    }
  }

  Future<double> applyCoupon(String couponCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/coupon'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'couponCode': couponCode}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['discount'] as num).toDouble();
      }
      throw Exception('Invalid Coupon');
    } catch (_) {
      // Mock validation
      if (couponCode.toUpperCase() == 'CLEAR10') {
        return 10.0;
      }
      throw Exception('Coupon code is invalid or has expired.');
    }
  }
}
