import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clear/core/controllers/rewards_controller.dart';
import 'package:clear/core/theme_controller.dart';
import 'package:clear/profile/controllers/referral_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(ThemeController());
    Get.put(RewardsController());
  });

  test('ReferralController generates well-formed code and validates inputs', () async {
    final controller = Get.put(ReferralController());
    
    // Default mock userId is '123'
    await controller.initReferral();
    expect(controller.myCode.value, 'USER123');

    // Attempt self-referral
    final selfSuccess = await controller.redeemConfirmationCode('USER123');
    expect(selfSuccess, false);
    expect(controller.redeemedCodes.contains('USER123'), false);

    // Attempt invalid code shape (only letters and numbers allowed)
    final invalidSuccess = await controller.redeemConfirmationCode('INV-482');
    expect(invalidSuccess, false);

    // Redeem valid code
    final rewards = Get.find<RewardsController>();
    expect(rewards.pointsBalance.value, 0);

    final success = await controller.redeemConfirmationCode('JANE482');
    expect(success, true);
    expect(controller.redeemedCodes.contains('JANE482'), true);
    expect(rewards.pointsBalance.value, 300); // Referrer gets 300 points

    // Redeem duplicate code
    final dupSuccess = await controller.redeemConfirmationCode('JANE482');
    expect(dupSuccess, false);
    expect(rewards.pointsBalance.value, 300); // Balance remains unchanged
  });
}
