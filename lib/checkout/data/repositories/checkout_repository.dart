import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../core/api_config.dart';

class CheckoutRepository {
  final String baseUrl = ApiConfig.baseUrl;

  static final List<AddressModel> mockAddresses = [];

  Future<List<AddressModel>> getAddresses() async {
    if (ApiConfig.isTest) {
      if (mockAddresses.isEmpty) {
        mockAddresses.addAll([
          AddressModel(id: 'addr1', name: 'Jane Doe', phone: '1234567890', street: '123 Glow Avenue', city: 'New York', pincode: '10001', state: 'NY'),
          AddressModel(id: 'addr2', name: 'John Doe', phone: '0987654321', street: '456 Radiance Blvd', city: 'San Francisco', pincode: '94105', state: 'CA'),
        ]);
      }
      return mockAddresses;
    }

    try {
      print("GET ADDRESSES CALL TO: $baseUrl/address");
      final response = await http.get(
        Uri.parse('$baseUrl/address'),
        headers: await ApiConfig.authHeaders(),
      );
      print("GET ADDRESSES STATUS CODE: ${response.statusCode}");
      print("GET ADDRESSES RESPONSE BODY: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data =
            ApiConfig.unwrap(decoded) as List<dynamic>? ?? [];
        return data
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (e) {
      print("GET ADDRESSES ERROR: $e");
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

    if (ApiConfig.isTest) {
      return created;
    }

    try {
      final payload = address.toJson();
      print("ADD ADDRESS PAYLOAD: $payload");
      final response = await http.post(
        Uri.parse('$baseUrl/address'),
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode(payload),
      );
      print("ADD ADDRESS STATUS CODE: ${response.statusCode}");
      print("ADD ADDRESS RESPONSE BODY: ${response.body}");
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddressModel.fromJson(
          ApiConfig.unwrap(decoded) as Map<String, dynamic>,
        );
      }
      throw Exception(ApiConfig.errorMessage(decoded));
    } catch (e) {
      print("ADD ADDRESS ERROR: $e");
      return created;
    }
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    final idx = mockAddresses.indexWhere((e) => e.id == address.id);
    if (idx != -1) {
      mockAddresses[idx] = address;
    }

    if (ApiConfig.isTest) {
      return address;
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

    if (ApiConfig.isTest) {
      return true;
    }

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
    if (ApiConfig.isTest) {
      return OrderModel(
        id: 'CLR-MOCK-111',
        date: 'Jul 20, 2026',
        total: 40.0,
        status: 'Processing',
        items: [],
        address: mockAddresses.first,
        paymentMethod: 'Card',
        subtotal: 50.0,
        discount: 10.0,
        deliveryFee: 0.0,
        trackingStages: [],
      );
    }

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
    if (ApiConfig.isTest) {
      return {
        'subtotal': 50.0,
        'discount': 10.0,
        'shipping': 0.0,
        'tax': 0.0,
        'total': 40.0,
      };
    }

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
