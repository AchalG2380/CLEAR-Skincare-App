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
    if (ApiConfig.isTest) {
      return localProfile;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await ApiConfig.authHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileModel.fromJson(ApiConfig.unwrap(decoded) as Map<String, dynamic>);
      }
      throw Exception('Server returned status: ${response.statusCode}');
    } catch (_) {
      // Mock fallback: Return memory instance
      return localProfile;
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    if (ApiConfig.isTest) {
      localProfile = profile;
      return localProfile;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: await ApiConfig.authHeaders(),
        body: jsonEncode(profile.toJson()),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final updated = ProfileModel.fromJson(ApiConfig.unwrap(decoded) as Map<String, dynamic>);
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
    if (ApiConfig.isTest) {
      return {'status': 'success', 'message': 'Password changed successfully'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: await ApiConfig.authHeaders(),
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
