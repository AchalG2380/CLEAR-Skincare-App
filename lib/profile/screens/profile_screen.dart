import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_strings.dart';
import '../../core/app_theme.dart';
import '../../core/theme_controller.dart';
import '../../core/widgets/app_widgets.dart';
import '../controllers/profile_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../core/controllers/rewards_controller.dart';
import '../controllers/referral_controller.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  Future<void> _logout() async {
    // 1. Wipe SharedPreferences credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.setBool('isLoggedIn', false);

    // 2. Wipe Cart Controller items
    Get.find<CartController>().clearCart();

    // 3. Wipe Wishlist Controller items
    Get.find<WishlistController>().clearWishlist();

    // 4. Redirect to login
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Reload profile data on visit
    controller.fetchProfile();

    return Obx(() {
      final isDark = Get.find<ThemeController>().isDarkMode.value;
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: SkincareAppBar(
          title: AppStrings.myProfileTitle,
          showBackButton: false,
        ),
        body: () {
          if (controller.isLoading.value && controller.profile.value == null) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final user = controller.profile.value;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : AppStrings.failedLoadProfile,
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchProfile,
            color: AppTheme.primary,
            backgroundColor: AppTheme.backgroundColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // User profile card
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.25),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name.substring(0, 2).toUpperCase()
                                  : 'JD',
                              style: TextStyle(
                                color: AppTheme.primaryText,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: TextStyle(
                            color: AppTheme.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: AppTheme.textDim,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.phone,
                          style: TextStyle(
                            color: AppTheme.textDim,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Points Balance Card
                  Obx(() {
                    final rewardsController = Get.find<RewardsController>();
                    final balance = rewardsController.pointsBalance.value;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              color: AppTheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$balance Points',
                                  style: TextStyle(
                                    color: AppTheme.primaryText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Redeem at checkout for discounts',
                                  style: TextStyle(
                                    color: AppTheme.textDim,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Options list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildProfileOption(
                          icon: Icons.person_outline,
                          title: AppStrings.editProfileTitle,
                          onTap: () => Get.toNamed('/edit-profile'),
                        ),
                        _buildProfileOption(
                          icon: Icons.lock_outline,
                          title: AppStrings.changePasswordTitle,
                          onTap: () => Get.toNamed('/change-password'),
                        ),
                        _buildProfileOption(
                          icon: Icons.location_on_outlined,
                          title: AppStrings.myAddressesTitle,
                          onTap: () => Get.toNamed('/my-addresses'),
                        ),
                        _buildProfileOption(
                          icon: Icons.shopping_bag_outlined,
                          title: AppStrings.myOrdersTitle,
                          onTap: () => Get.toNamed('/orders'),
                        ),
                        _buildProfileOption(
                          icon: Icons.calendar_today_outlined,
                          title: 'Skincare Routine Planner',
                          onTap: () => Get.toNamed('/routine-planner'),
                        ),

                        // Dark Mode Toggle Switch
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isDark
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                            title: Text(
                              isDark ? "Dark Mode" : "Light Mode",
                              style: TextStyle(
                                color: AppTheme.primaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Switch(
                              value: isDark,
                              onChanged: (val) =>
                                  Get.find<ThemeController>().toggleTheme(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Referral Section Title
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Referrals & Rewards",
                            style: TextStyle(
                              color: AppTheme.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Invite Friends Card
                        Obx(() {
                          final referralController = Get.find<ReferralController>();
                          final code = referralController.myCode.value;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Invite Friends",
                                  style: TextStyle(
                                    color: AppTheme.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Share your code with friends. You both get bonus points when they join and share back!",
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.inputFill,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primary.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      code.isNotEmpty ? code : 'GENERATING...',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                            text: "Join CLEAR Skincare app using my referral code $code to get 200 welcome points!",
                                          ));
                                          Get.snackbar(
                                            'Invite Copied',
                                            'Invitation message has been copied to your clipboard!',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppTheme.cardBackground.withValues(alpha: 0.95),
                                            colorText: Colors.white,
                                          );
                                        },
                                        icon: const Icon(Icons.share_outlined, size: 16),
                                        label: const Text("Share Invite"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.primary,
                                          side: BorderSide(color: AppTheme.primary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: code));
                                          Get.snackbar(
                                            'Code Copied',
                                            'Code $code copied to clipboard!',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppTheme.cardBackground.withValues(alpha: 0.95),
                                            colorText: Colors.white,
                                          );
                                        },
                                        icon: const Icon(Icons.copy_all_outlined, size: 16),
                                        label: const Text("Copy Code"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.buttonColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Redeem Friend's Code Card
                        Builder(
                          builder: (context) {
                            final redeemTextController = TextEditingController();
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.12),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Redeem a Friend's Confirmation",
                                    style: TextStyle(
                                      color: AppTheme.primaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Enter the code your friend sent you to claim your 300 points reward.",
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 46,
                                          child: TextField(
                                            controller: redeemTextController,
                                            style: TextStyle(color: AppTheme.primaryText, fontSize: 13),
                                            cursorColor: AppTheme.primary,
                                            decoration: InputDecoration(
                                              hintText: "Friend's code (e.g. JANE482)",
                                              hintStyle: TextStyle(
                                                color: AppTheme.textHint,
                                                fontSize: 12,
                                              ),
                                              filled: true,
                                              fillColor: AppTheme.inputFill,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                  color: AppTheme.primary.withValues(alpha: 0.18),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: BorderSide(color: AppTheme.primary),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final referralController = Get.find<ReferralController>();
                                          final success = await referralController.redeemConfirmationCode(
                                            redeemTextController.text,
                                          );
                                          if (success) {
                                            redeemTextController.clear();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.buttonColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          minimumSize: const Size(90, 46),
                                        ),
                                        child: const Text(
                                          "Redeem",
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Expandable Referral Activity list
                        Obx(() {
                          final referralController = Get.find<ReferralController>();
                          final activity = referralController.referralActivity;
                          final count = activity.length;

                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                width: 1,
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: Icon(Icons.people_outline, color: AppTheme.primary, size: 22),
                                title: Text(
                                  count == 1 ? "1 friend redeemed" : "$count friends redeemed",
                                  style: TextStyle(
                                    color: AppTheme.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  if (activity.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        "No referral activity logged yet.",
                                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: activity.length,
                                      separatorBuilder: (_, __) => Divider(color: AppTheme.dividerColor, height: 1),
                                      itemBuilder: (context, index) {
                                        final item = activity[index];
                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            item,
                                            style: TextStyle(color: AppTheme.primaryText, fontSize: 13),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Logout button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              AppStrings.logout,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorBg.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }(),
      );
    });
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.primary, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: AppTheme.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppTheme.textDark, size: 20),
      ),
    );
  }
}
