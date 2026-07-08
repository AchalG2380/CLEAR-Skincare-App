import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Loading state — screen watches this to show/hide spinner
  var isLoading = false.obs;

  // Carries over between auth screens (Forgot Password -> OTP -> Reset)
  var emailForFlow = ''.obs;

  // Basic email regex validator
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result.token);
      await prefs.setString('userId', result.userId);
      await prefs.setBool('isLoggedIn', true);

      isLoading.value = false;

      Get.offAllNamed('/home');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Login Failed', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      isLoading.value = false;
      Get.snackbar('Success', 'Registered successfully! Please log in.',
          snackPosition: SnackPosition.BOTTOM);
      
      Get.offAllNamed('/login');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Registration Failed', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email address',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      await _authRepository.forgotPassword(email: email);
      emailForFlow.value = email;

      isLoading.value = false;
      Get.snackbar('OTP Sent', 'An OTP has been sent to your email',
          snackPosition: SnackPosition.BOTTOM);
      
      Get.toNamed('/verify-otp');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      await _authRepository.verifyOtp(
        email: emailForFlow.value,
        otp: otp,
      );

      isLoading.value = false;
      Get.snackbar('OTP Verified', 'OTP verified successfully!',
          snackPosition: SnackPosition.BOTTOM);
      
      Get.toNamed('/reset-password');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Verification Failed', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> resetPassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      await _authRepository.resetPassword(
        email: emailForFlow.value,
        password: password,
      );

      isLoading.value = false;
      Get.snackbar('Success', 'Password reset successfully! Please log in.',
          snackPosition: SnackPosition.BOTTOM);
      
      Get.offAllNamed('/login');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Reset Failed', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
