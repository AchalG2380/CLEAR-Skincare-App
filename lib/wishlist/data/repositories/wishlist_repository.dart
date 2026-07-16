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
        headers: await ApiConfig.authHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            ApiConfig.unwrap(jsonDecode(response.body)) as List<dynamic>;
        return data
            .where((e) => e['product'] != null)
            .map((e) => ProductModel.fromJson(e['product'] as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Server returned ${response.statusCode}');
    } catch (_) {
      return [];
    }
  }

  Future<void> addToWishlist(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wishlist'),
        headers: await ApiConfig.authHeaders(),
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
        headers: await ApiConfig.authHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (_) {
      // Fallback silently for mock demo
    }
  }
}
