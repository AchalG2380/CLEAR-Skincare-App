import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/app_widgets.dart';
import '../controllers/profile_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../cart/controllers/cart_controller.dart';
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

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: const SkincareAppBar(title: 'My Profile', showBackButton: false),
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8C6EFF)),
          );
        }

        final user = controller.profile.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Failed to load profile data',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          color: const Color(0xFF8C6EFF),
          backgroundColor: const Color(0xFF130538),
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
                          border: Border.all(color: const Color(0xFF8C6EFF), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8C6EFF).withValues(alpha: 0.25),
                              blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name.substring(0, 2).toUpperCase() : 'JD',
                        style: const TextStyle(
                          color: Colors.white,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Options list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () => Get.toNamed('/edit-profile'),
                  ),
                  _buildProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => Get.toNamed('/change-password'),
                  ),
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    title: 'My Addresses',
                    onTap: () => Get.toNamed('/my-addresses'),
                  ),
                  _buildProfileOption(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    onTap: () => Get.toNamed('/orders'),
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828).withValues(alpha: 0.8),
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
  }),
);
}

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(30, 140, 110, 255),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFFC7B6FF), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
      ),
    );
  }
}
