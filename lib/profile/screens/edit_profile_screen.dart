import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../../auth/screens/widgets/auth_widgets.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final user = controller.profile.value;

    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profile',
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
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColor.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              AuthTextField(
                controller: nameController,
                labelText: 'Name',
                hintText: 'Enter your Name',
                prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
              ),

              AuthTextField(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Enter your Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
              ),

              AuthTextField(
                controller: phoneController,
                labelText: 'Phone Number',
                hintText: 'Enter your Phone Number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white70),
              ),

              const SizedBox(height: 30),

              Obx(
                () => AuthButton(
                  text: 'Save Changes',
                  isLoading: controller.isSaving.value,
                  onPressed: () async {
                    final success = await controller.updateProfile(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
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
