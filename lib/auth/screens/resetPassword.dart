import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../screens/widgets/auth_widgets.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Set your new account password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(180, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 48),

                // Card-like Container
                Container(
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
                    children: [
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Password field
                      AuthTextField(
                        controller: passwordController,
                        labelText: 'New Password',
                        hintText: 'Enter your New Password',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                      ),

                      // Confirm Password field
                      AuthTextField(
                        controller: confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your New Password',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),

                      // Reset Password button
                      Obx(
                        () => AuthButton(
                          text: 'Reset Password',
                          isLoading: authController.isLoading.value,
                          onPressed: () {
                            authController.resetPassword(
                              password: passwordController.text.trim(),
                              confirmPassword: confirmPasswordController.text.trim(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
