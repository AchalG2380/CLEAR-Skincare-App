import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../controllers/auth_controller.dart';
import '../screens/widgets/auth_widgets.dart';

class VerifyOTPScreen extends StatefulWidget {
  const VerifyOTPScreen({super.key});

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final AuthController authController = Get.find<AuthController>();
  final otpController = TextEditingController();
  
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _resendOtp() {
    if (!_canResend) return;
    
    // Call repository / controller to resend OTP
    authController.forgotPassword(email: authController.emailForFlow.value);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
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
                  AppStrings.verificationRequired,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.secondaryText,
                  ),
                ),
                const SizedBox(height: 48),

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
                        AppStrings.verifyOtpHeader,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Text(
                          AppStrings.enterOtpSentTo + authController.emailForFlow.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Custom OTP boxes widget
                      OtpInputWidget(
                        controller: otpController,
                        length: 6,
                        onCompleted: (code) {
                          authController.verifyOtp(otp: code);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Resend OTP countdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.resendOtpPrompt,
                            style: TextStyle(color: AppColor.textMuted, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: _canResend ? _resendOtp : null,
                            child: Text(
                              _canResend
                                  ? AppStrings.resendOtp
                                  : AppStrings.resendIn(_secondsRemaining),
                              style: TextStyle(
                                color: _canResend
                                    ? AppColor.primary
                                    : AppColor.primary.withValues(alpha: 0.3),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Verify button
                      Obx(
                        () => AuthButton(
                          text: AppStrings.verify,
                          isLoading: authController.isLoading.value,
                          onPressed: () {
                            authController.verifyOtp(
                              otp: otpController.text.trim(),
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
