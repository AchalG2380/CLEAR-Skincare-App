import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardsController extends GetxController {
  static const String _keyRewardPoints = 'reward_points';

  final pointsBalance = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      pointsBalance.value = prefs.getInt(_keyRewardPoints) ?? 0;
    } catch (_) {
      pointsBalance.value = 0;
    }
  }

  Future<void> applyOrderResult({required int redeemed, required int earned}) async {
    try {
      final newBalance = pointsBalance.value - redeemed + earned;
      pointsBalance.value = newBalance < 0 ? 0 : newBalance;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyRewardPoints, pointsBalance.value);
    } catch (_) {
      // Fail silently but preserve in-memory update
    }
  }

  Future<void> setBalance(int balance) async {
    try {
      pointsBalance.value = balance < 0 ? 0 : balance;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyRewardPoints, pointsBalance.value);
    } catch (_) {}
  }
}
