import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../../auth/screens/widgets/auth_widgets.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF130538),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 255, 255, 255),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromARGB(50, 140, 110, 255),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security Credentials',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              AuthTextField(
                controller: currentPasswordController,
                labelText: 'Current Password',
                hintText: 'Enter your Current Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
              ),

              AuthTextField(
                controller: newPasswordController,
                labelText: 'New Password',
                hintText: 'Enter your New Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
              ),

              AuthTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm New Password',
                hintText: 'Re-enter your New Password',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
              ),

              const SizedBox(height: 30),

              Obx(
                () => AuthButton(
                  text: 'Change Password',
                  isLoading: controller.isChangingPassword.value,
                  onPressed: () async {
                    final success = await controller.changePassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                      confirmPassword: confirmPasswordController.text,
                    );
                    if (success) {
                      Get.back();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
