import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../home/data/models/product_model.dart';
import '../../../core/api_config.dart';

class WishlistRepository {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wishlist'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
      throw Exception('Server returned ${response.statusCode}');
    } catch (_) {
      // Mock wishlist data containing a couple of defaults from the catalogue
      return [
        ProductModel(
          id: 's1',
          name: 'Vitamin C Radiance Serum',
          imageUrl: 'assets/images/Serum.jpg',
          price: 29.99,
          rating: 4.8,
          isWishlisted: true,
          category: 'cat_serum',
          concern: 'Dark Spots',
        ),
        ProductModel(
          id: 'sun1',
          name: 'Matte Fluid SPF 50+',
          imageUrl: 'assets/images/moisturrizer2.webp',
          price: 22.00,
          rating: 4.9,
          isWishlisted: true,
          category: 'cat_sunscreen',
          concern: 'Acne & Blemishes',
        ),
      ];
    }
  }

  Future<void> addToWishlist(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wishlist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (_) {
      // Fallback silently for mock demo
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/wishlist/$productId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (_) {
      // Fallback silently for mock demo
    }
  }
}
