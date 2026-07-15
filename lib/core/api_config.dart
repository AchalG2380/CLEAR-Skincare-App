class ApiConfig {
  static const String baseUrl =
      'http://localhost:5000/api'; // adjust per Phase 0 table

  /// Every response from this backend is wrapped as:
  /// { "success": bool, "message": string, "data": <actual payload> }
  /// This pulls the real payload out — call it right after jsonDecode()
  /// on every successful response, before passing to any fromJson().
  static dynamic unwrap(Map<String, dynamic> decoded) {
    return decoded['data'];
  }

  static String errorMessage(Map<String, dynamic> decoded) {
    return decoded['message'] ?? 'Something went wrong. Please try again.';
  }
}
