import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the order id passed as argument
    final String orderId = Get.arguments as String? ?? 'CLR-UNKNOWN';

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Glowing Success Checkmark Circle
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8C6EFF), Color(0xFFC7B6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8C6EFF).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Title
              const Text(
                'Order Placed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle/Message
              const Text(
                'Your skincare order has been received and is being processed by our laboratory.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Order ID Display Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(15, 255, 255, 255),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromARGB(30, 140, 110, 255),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ORDER ID',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderId,
                      style: const TextStyle(
                        color: Color(0xFFC7B6FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Continue Shopping Button (resets route stack)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C6EFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
