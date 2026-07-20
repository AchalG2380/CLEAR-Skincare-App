import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/controllers/rewards_controller.dart';
import '../../core/theme_controller.dart';
import '../controllers/profile_controller.dart';

class ReferralController extends GetxController {
  final myCode = ''.obs;
  final redeemedCodes = <String>[].obs;
  final referralActivity = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    initReferral();
    // Re-run init when profile changes to make sure name is loaded
    if (Get.isRegistered<ProfileController>()) {
      ever(Get.find<ProfileController>().profile, (_) => initReferral());
    }
  }

  Future<void> initReferral() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      var code = prefs.getString('my_referral_code') ?? '';
      if (code.isEmpty) {
        String name = 'USER';
        if (Get.isRegistered<ProfileController>()) {
          final profileVal = Get.find<ProfileController>().profile.value;
          if (profileVal != null && profileVal.name.isNotEmpty) {
            name = profileVal.name;
          }
        }
        final userId = prefs.getString('userId') ?? '123';
        code = _generateUserReferralCode(name, userId);
        await prefs.setString('my_referral_code', code);
      }
      myCode.value = code;

      // Load logs
      redeemedCodes.assignAll(prefs.getStringList('redeemed_referral_codes') ?? []);
      referralActivity.assignAll(prefs.getStringList('referral_activity') ?? []);
    } catch (_) {}
  }

  String _generateUserReferralCode(String name, String userId) {
    final cleanName = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    final prefix = cleanName.isNotEmpty ? (cleanName.length > 5 ? cleanName.substring(0, 5) : cleanName) : 'USER';
    final suffix = userId.length > 3 ? userId.substring(userId.length - 3) : userId;
    return '$prefix$suffix';
  }

  Future<bool> redeemConfirmationCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    
    if (cleanCode.length < 3 || cleanCode.length > 12) {
      _showSnackbar('Invalid Code', 'Referral codes must be between 3 and 12 characters.');
      return false;
    }
    if (cleanCode == myCode.value) {
      _showSnackbar('Self Referral', 'You cannot redeem your own referral code.');
      return false;
    }
    if (redeemedCodes.contains(cleanCode)) {
      _showSnackbar('Already Redeemed', 'You have already claimed a reward for this code.');
      return false;
    }

    // Check code pattern (e.g. alphanumeric name prefix followed by user id/phone digits)
    final codeRegex = RegExp(r'^[A-Z0-9]+$');
    if (!codeRegex.hasMatch(cleanCode)) {
      _showSnackbar('Invalid Code', 'Referral code must only contain letters and numbers.');
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      redeemedCodes.add(cleanCode);
      await prefs.setStringList('redeemed_referral_codes', redeemedCodes);

      final dateStr = _getCurrentFormattedDate();
      final logMsg = 'Redeemed $cleanCode · $dateStr';
      referralActivity.insert(0, logMsg);
      await prefs.setStringList('referral_activity', referralActivity);

      // Grant 300 points ($3.00)
      if (Get.isRegistered<RewardsController>()) {
        await Get.find<RewardsController>().applyOrderResult(redeemed: 0, earned: 300);
      }

      _showSnackbar('Success', 'Successfully redeemed! 300 points added to your balance.');
      return true;
    } catch (_) {
      _showSnackbar('Error', 'Failed to redeem referral code.');
      return false;
    }
  }

  String _getCurrentFormattedDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}';
  }

  void _showSnackbar(String title, String message) {
    if (Get.context == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.find<ThemeController>().isDarkMode.value
          ? const Color(0xFF151B2E).withValues(alpha: 0.95)
          : Colors.grey[850]!.withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
