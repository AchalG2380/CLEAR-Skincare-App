import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/checkout_controller.dart';
import 'checkout_address_screen.dart';

class CheckoutPaymentScreen extends StatelessWidget {
  CheckoutPaymentScreen({super.key});

  // Find the existing CheckoutController
  final CheckoutController controller = Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
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
          'Payment Method',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          const CheckoutStepIndicator(currentStep: 1),

          // Payment Options list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Payment Methods Options
                _buildPaymentMethodOption(
                  method: 'Card',
                  title: 'Credit / Debit Card',
                  icon: Icons.credit_card_outlined,
                ),
                _buildPaymentMethodOption(
                  method: 'UPI',
                  title: 'UPI (Paytm, GPay, PhonePe)',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _buildPaymentMethodOption(
                  method: 'COD',
                  title: 'Cash on Delivery (COD)',
                  icon: Icons.payments_outlined,
                ),
              ],
            ),
          ),

          // Sticky bottom continue button
          _buildBottomActionPanel(),
        ],
      ),
    );
  }

  // ─── Individual Payment Selector Option ─────────────────────────────────────
  Widget _buildPaymentMethodOption({
    required String method,
    required String title,
    required IconData icon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == method;
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              controller.selectedPaymentMethod.value = method;
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(35, 140, 110, 255)
                    : const Color.fromARGB(15, 255, 255, 255),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8C6EFF)
                      : const Color.fromARGB(30, 140, 110, 255),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? const Color(0xFF8C6EFF) : Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Icon(icon, color: Colors.white70, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Render Card entry form if Card is selected
          if (isSelected && method == 'Card')
            _buildCardInputForm(),

          const SizedBox(height: 12),
        ],
      );
    });
  }

  // ─── Dummy Card Entry Form ──────────────────────────────────────────────────
  Widget _buildCardInputForm() {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 4, right: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(25, 19, 5, 56),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(30, 140, 110, 255),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Card Number Field
          TextFormField(
            onChanged: (val) => controller.cardNumber.value = val,
            initialValue: controller.cardNumber.value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            keyboardType: TextInputType.number,
            cursorColor: const Color(0xFF8C6EFF),
            decoration: _buildInputDecoration(
              labelText: 'Card Number',
              hintText: 'XXXX XXXX XXXX XXXX',
            ),
          ),
          const SizedBox(height: 12),

          // Expiry and CVV Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  onChanged: (val) => controller.cardExpiry.value = val,
                  initialValue: controller.cardExpiry.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  keyboardType: TextInputType.datetime,
                  cursorColor: const Color(0xFF8C6EFF),
                  decoration: _buildInputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  onChanged: (val) => controller.cardCvv.value = val,
                  initialValue: controller.cardCvv.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  cursorColor: const Color(0xFF8C6EFF),
                  decoration: _buildInputDecoration(
                    labelText: 'CVV',
                    hintText: '***',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
      filled: true,
      fillColor: const Color.fromARGB(15, 255, 255, 255),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromARGB(20, 140, 110, 255)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF8C6EFF)),
      ),
    );
  }

  // ─── Sticky Bottom Action Bar ───────────────────────────────────────────────
  Widget _buildBottomActionPanel() {
    return Container(
      color: const Color(0xFF130538),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isEnabled = controller.selectedPaymentMethod.value.isNotEmpty;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isEnabled
                  ? () => Get.toNamed('/checkout-review')
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C6EFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF8C6EFF).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Continue to Review',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
