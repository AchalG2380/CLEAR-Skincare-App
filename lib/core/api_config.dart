import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://localhost:5000/api';

  static dynamic unwrap(Map<String, dynamic> decoded) => decoded['data'];
  static String errorMessage(Map<String, dynamic> decoded) =>
      decoded['message'] ?? 'Something went wrong. Please try again.';

  static bool get isTest {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Every protected endpoint (everything except the 5 auth endpoints)
  /// requires this — without it, the backend returns 401 on every call.
  static Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
