import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          AppStrings.changePasswordTitle,
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
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.securityCredentialsTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              AuthTextField(
                controller: currentPasswordController,
                labelText: AppStrings.currentPassword,
                hintText: AppStrings.hintCurrentPassword,
                obscureText: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Colors.white70,
                ),
              ),

              AuthTextField(
                controller: newPasswordController,
                labelText: AppStrings.newPassword,
                hintText: AppStrings.hintNewPassword,
                obscureText: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Colors.white70,
                ),
              ),

              AuthTextField(
                controller: confirmPasswordController,
                labelText: AppStrings.confirmPassword,
                hintText: AppStrings.hintConfirmPassword,
                obscureText: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              Obx(
                () => AuthButton(
                  text: AppStrings.changePassword,
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
