import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../controllers/checkout_controller.dart';
import 'checkout_address_screen.dart';

class CheckoutPaymentScreen extends StatelessWidget {
  CheckoutPaymentScreen({super.key});

  // Find the existing CheckoutController
  final CheckoutController controller = Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
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
          AppStrings.paymentMethodTitle,
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
                  AppStrings.selectPaymentHeader,
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
                  title: AppStrings.cardText,
                  icon: Icons.credit_card_outlined,
                ),
                _buildPaymentMethodOption(
                  method: 'UPI',
                  title: AppStrings.upiTextSubtitle,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _buildPaymentMethodOption(
                  method: 'COD',
                  title: AppStrings.codTextSubtitle,
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
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.primary.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppTheme.primary : Colors.white54,
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
          if (isSelected && method == 'Card') _buildCardInputForm(),

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
        color: AppTheme.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Card Number Field
          TextFormField(
            onChanged: (val) => controller.cardNumber.value = val,
            initialValue: controller.cardNumber.value,
            style: TextStyle(color: AppTheme.primaryText, fontSize: 13),
            keyboardType: TextInputType.number,
            cursorColor: AppTheme.primary,
            decoration: _buildInputDecoration(
              labelText: AppStrings.cardNumber,
              hintText: AppStrings.hintCardNumber,
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
                  style: TextStyle(color: AppTheme.primaryText, fontSize: 13),
                  keyboardType: TextInputType.datetime,
                  cursorColor: AppTheme.primary,
                  decoration: _buildInputDecoration(
                    labelText: AppStrings.labelExpiryDate,
                    hintText: AppStrings.cardExpiry,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  onChanged: (val) => controller.cardCvv.value = val,
                  initialValue: controller.cardCvv.value,
                  style: TextStyle(color: AppTheme.primaryText, fontSize: 13),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  cursorColor: AppTheme.primary,
                  decoration: _buildInputDecoration(
                    labelText: AppStrings.cardCvv,
                    hintText: AppStrings.hintCvv,
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
      labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
      hintText: hintText,
      hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 12),
      filled: true,
      fillColor: AppTheme.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppTheme.primary),
      ),
    );
  }

  // ─── Sticky Bottom Action Bar ───────────────────────────────────────────────
  Widget _buildBottomActionPanel() {
    return Container(
      color: AppTheme.backgroundColor,
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
                backgroundColor: AppTheme.buttonColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.buttonColor.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                AppStrings.continueToReview,
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
