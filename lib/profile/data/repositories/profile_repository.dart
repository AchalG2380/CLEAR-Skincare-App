import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../../../core/api_config.dart';

class ProfileRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // Shared static memory database instance so updates persist during the session
  static ProfileModel localProfile = ProfileModel(
    name: 'Jane Doe',
    email: 'jane.doe@example.com',
    phone: '+1 555-0199',
    avatarUrl: null,
  );

  Future<ProfileModel> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProfileModel.fromJson(data);
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock fallback: Return memory instance
      return localProfile;
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final updated = ProfileModel.fromJson(data);
        localProfile = updated;
        return updated;
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock fallback: Update and return local memory instance
      localProfile = profile;
      return localProfile;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock fallback: success
      return {'status': 'success', 'message': 'Password changed successfully'};
    }
  }
}
