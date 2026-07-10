import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/product_widgets.dart';
import '../controllers/checkout_controller.dart';
import 'checkout_address_screen.dart';

class CheckoutReviewScreen extends StatelessWidget {
  CheckoutReviewScreen({super.key});

  // Find the existing CheckoutController
  final CheckoutController controller = Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
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
          AppStrings.orderReviewTitle,
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
          const CheckoutStepIndicator(currentStep: 2),

          // Review scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Shipping Address Section
                _buildSectionHeader(
                  AppStrings.deliveryAddress,
                  onEdit: () =>
                      Get.until((route) => route.settings.name == '/checkout'),
                ),
                _buildAddressSummaryCard(),

                const SizedBox(height: 20),

                // 2. Payment Method Section
                _buildSectionHeader(AppStrings.paymentMethod, onEdit: () => Get.back()),
                _buildPaymentSummaryCard(),

                const SizedBox(height: 20),

                // 3. Items list recap
                const Text(
                  AppStrings.itemsSummary,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildItemsListCard(),

                const SizedBox(height: 20),

                // 4. Order Price Summary Card
                const Text(
                  AppStrings.billingDetails,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildPriceSummaryCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Sticky Place Order Button
          _buildBottomActionPanel(),
        ],
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {required VoidCallback onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onEdit,
          child: const Text(
            AppStrings.change,
            style: TextStyle(
              color: AppColor.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Address Summary Card ───────────────────────────────────────────────────
  Widget _buildAddressSummaryCard() {
    final address = controller.selectedAddress.value;
    if (address == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            address.street,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          Text(
            '${address.city}, ${address.state} - ${address.pincode}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.labelPhone}: ${address.phone}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Payment Summary Card ───────────────────────────────────────────────────
  Widget _buildPaymentSummaryCard() {
    final method = controller.selectedPaymentMethod.value;
    String displayTitle = '';
    IconData displayIcon = Icons.payment;

    if (method == 'Card') {
      displayTitle = AppStrings.cardText;
      final cardNo = controller.cardNumber.value;
      if (cardNo.isNotEmpty) {
        final masked = cardNo.length > 4
            ? '**** **** **** ${cardNo.substring(cardNo.length - 4)}'
            : '**** **** **** $cardNo';
        displayTitle += '\n$masked';
      }
      displayIcon = Icons.credit_card_outlined;
    } else if (method == 'UPI') {
      displayTitle = AppStrings.upiWallet;
      displayIcon = Icons.account_balance_wallet_outlined;
    } else if (method == 'COD') {
      displayTitle = AppStrings.codText;
      displayIcon = Icons.payments_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(displayIcon, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Text(
            displayTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Items List Card ────────────────────────────────────────────────────────
  Widget _buildItemsListCard() {
    return Column(
      children: controller.items.map<Widget>((item) {
        final prod = item['product'] as Map<String, dynamic>? ?? {};
        final name = prod['name'] as String? ?? 'Product';
        final imageUrl = prod['imageUrl'] as String? ?? '';
        final price = (prod['price'] as num?)?.toDouble() ?? 0.0;
        final qty = item['quantity'] as int? ?? 1;

        return SkincareCartItemRow(
          name: name,
          imageUrl: imageUrl,
          price: price,
          quantity: qty,
          isEditable: false,
        );
      }).toList(),
    );
  }

  // ─── Price Summary Card ─────────────────────────────────────────────────────
  Widget _buildPriceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            AppStrings.subtotal,
            '\$${controller.subtotal.value.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          if (controller.discount.value > 0) ...[
            _buildPriceRow(
              AppStrings.discount,
              '-\$${controller.discount.value.toStringAsFixed(2)}',
              valueColor: AppColor.discountColor,
            ),
            const SizedBox(height: 8),
          ],
          _buildPriceRow(
            AppStrings.deliveryFee,
            controller.deliveryFee.value == 0.0
                ? AppStrings.freeShipping
                : '\$${controller.deliveryFee.value.toStringAsFixed(2)}',
            valueColor: controller.deliveryFee.value == 0.0
                ? AppColor.freeShipping
                : Colors.white,
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildPriceRow(
            AppStrings.totalAmount,
            '\$${controller.total.value.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white60,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColor.primary : valueColor,
            fontSize: isTotal ? 18 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─── Sticky Place Order Bottom Panel ────────────────────────────────────────
  Widget _buildBottomActionPanel() {
    return Container(
      color: AppColor.backgroundColor,
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isPlacing = controller.isPlacingOrder.value;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isPlacing ? null : () => controller.placeOrder(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isPlacing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      AppStrings.placeOrder,
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
