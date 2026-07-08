import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
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
                  'Verification Required',
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
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => Text(
                          'Enter the 6-digit OTP sent to\n${authController.emailForFlow.value}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(140, 255, 255, 255),
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
                            "Didn't receive the code? ",
                            style: TextStyle(color: Color.fromARGB(140, 255, 255, 255), fontSize: 13),
                          ),
                          TextButton(
                            onPressed: _canResend ? _resendOtp : null,
                            child: Text(
                              _canResend ? 'Resend OTP' : 'Resend in ${_secondsRemaining}s',
                              style: TextStyle(
                                color: _canResend
                                    ? const Color.fromARGB(255, 255, 182, 182)
                                    : const Color.fromARGB(80, 255, 182, 182),
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
                          text: 'Verify OTP',
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
