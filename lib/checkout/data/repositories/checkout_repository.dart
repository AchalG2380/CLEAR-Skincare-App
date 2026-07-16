import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../core/api_config.dart';

class CheckoutRepository {
  final String baseUrl = ApiConfig.baseUrl;

  static final List<AddressModel> mockAddresses = [];

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: await ApiConfig.authHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            ApiConfig.unwrap(jsonDecode(response.body)) as List<dynamic>;
        return data
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return [];
    }
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final newId = address.id.isEmpty
        ? '6a58a0ed750bff6280d85${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}'
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
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode(address.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return AddressModel.fromJson(
          ApiConfig.unwrap(decoded) as Map<String, dynamic>,
        );
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
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode(address.toJson()),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return AddressModel.fromJson(
          ApiConfig.unwrap(decoded) as Map<String, dynamic>,
        );
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return address;
    }
  }

  Future<bool> deleteAddress(String id) async {
    mockAddresses.removeWhere((e) => e.id == id);

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/address/$id'),
        headers: await ApiConfig.authHeaders(),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return true;
    }
  }

  Future<OrderModel> placeOrder({required String addressId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'), // note: /orders, NOT /checkout
      headers: await ApiConfig.authHeaders(),
      body: jsonEncode({'addressId': addressId}),
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderModel.fromJson(ApiConfig.unwrap(decoded));
    }
    throw Exception(ApiConfig.errorMessage(decoded));
  }

  Future<Map<String, dynamic>> getCheckoutSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checkout'),
        headers: await ApiConfig.authHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiConfig.unwrap(decoded) as Map<String, dynamic>;
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      return {
        'subtotal': 0.0,
        'discount': 0.0,
        'shipping': 0.0,
        'tax': 0.0,
        'total': 0.0,
      };
    }
  }
}
