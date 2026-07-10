import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_strings.dart';
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
      Get.snackbar(AppStrings.errTitle, AppStrings.valAllFieldsRequired,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valEmailInvalid,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password.length < 6) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valPasswordLength,
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
      Get.snackbar(AppStrings.loginFailed, e.toString().replaceAll('Exception: ', ''),
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
      Get.snackbar(AppStrings.errTitle, AppStrings.valAllFieldsRequired,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valEmailInvalid,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password.length < 6) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valPasswordLength,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valPasswordMismatch,
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
      Get.snackbar(AppStrings.successTitle, AppStrings.regSuccess,
          snackPosition: SnackPosition.BOTTOM);
      
      Get.offAllNamed('/login');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(AppStrings.regFailed, e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    if (email.isEmpty) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valEmailEmpty,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valEmailInvalid,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      await _authRepository.forgotPassword(email: email);
      emailForFlow.value = email;

      isLoading.value = false;
      Get.snackbar(AppStrings.otpSentTitle, AppStrings.otpSentMsg,
          snackPosition: SnackPosition.BOTTOM);
      
      Get.toNamed('/verify-otp');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(AppStrings.errTitle, e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valOtpLength,
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
      Get.snackbar(AppStrings.otpVerifiedTitle, AppStrings.otpVerifiedMsg,
          snackPosition: SnackPosition.BOTTOM);
      
      Get.toNamed('/reset-password');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(AppStrings.verificationFailed, e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> resetPassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valAllFieldsRequired,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password.length < 6) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valPasswordLength,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(AppStrings.errTitle, AppStrings.valPasswordMismatch,
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
      Get.snackbar(AppStrings.successTitle, AppStrings.resetSuccess,
          snackPosition: SnackPosition.BOTTOM);
      
      Get.offAllNamed('/login');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(AppStrings.resetFailed, e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
