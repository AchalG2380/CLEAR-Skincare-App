import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../screens/widgets/auth_widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 36),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.welcomeTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.secondaryText,
                ),
              ),
              const SizedBox(height: 24),

              // Card-like Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColor.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      AppStrings.register,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    AuthTextField(
                      controller: nameController,
                      labelText: AppStrings.labelName,
                      hintText: AppStrings.hintName,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                    ),

                    AuthTextField(
                      controller: phoneController,
                      labelText: AppStrings.labelPhone,
                      hintText: AppStrings.hintPhone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: Colors.white70,
                      ),
                    ),

                    AuthTextField(
                      controller: emailController,
                      labelText: AppStrings.labelEmail,
                      hintText: AppStrings.hintEmail,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                    ),

                    AuthTextField(
                      controller: passwordController,
                      labelText: AppStrings.labelPassword,
                      hintText: AppStrings.hintPassword,
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                    ),

                    AuthTextField(
                      controller: confirmPasswordController,
                      labelText: AppStrings.labelConfirmPassword,
                      hintText: AppStrings.confirmPassword,
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register button — reacts to isLoading
                    Obx(
                      () => AuthButton(
                        text: AppStrings.register,
                        isLoading: authController.isLoading.value,
                        onPressed: () {
                          authController.register(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phone: phoneController.text.trim(),
                            password: passwordController.text.trim(),
                            confirmPassword: confirmPasswordController.text
                                .trim(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.haveAccount,
                    style: TextStyle(color: AppColor.secondaryText),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed('/login');
                    },
                    child: const Text(
                      AppStrings.login,
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
