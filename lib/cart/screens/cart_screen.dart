import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_strings.dart';
import '../../core/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/product_widgets.dart';
import '../controllers/cart_controller.dart';
import '../../core/controllers/rewards_controller.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController controller = Get.find<CartController>();
  final TextEditingController _couponTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          title: Text(
            AppStrings.cartTitle,
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.cartItems.isEmpty) {
            return _buildShimmerLoading();
          }

          if (controller.cartItems.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: controller.fetchCart,
            color: AppTheme.primary,
            backgroundColor: AppTheme.backgroundColor,
            child: Column(
              children: [
                // Scrollable List of Cart Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),

                // Pinned Bottom Section for Summary & Coupon
                _buildBottomSummaryPanel(context),
              ],
            ),
          );
        }),
      );
    });
  }

  // ─── Individual Cart Item Row ──────────────────────────────────────────────
  Widget _buildCartItem(dynamic item) {
    return Dismissible(
      key: Key('cart_${item.product.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        controller.removeFromCart(item.cartItemId);
      },
      child: SkincareCartItemRow(
        name: item.product.name,
        imageUrl: item.product.imageUrl,
        price: item.product.price,
        quantity: item.quantity,
        isEditable: true,
        onIncrement: () => controller.updateQuantity(item.cartItemId, 1),
        onDecrement: () => controller.updateQuantity(item.cartItemId, -1),
        onRemove: () => controller.removeFromCart(item.cartItemId),
      ),
    );
  }

  // ─── Pinned Summary & Coupon Section ────────────────────────────────────────
  Widget _buildBottomSummaryPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Coupon Input
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _couponTextController,
                    style: TextStyle(color: AppTheme.primaryText, fontSize: 13),
                    cursorColor: AppTheme.primary,
                    decoration: InputDecoration(
                      hintText: AppStrings.hintCoupon,
                      hintStyle: TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: AppTheme.inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppTheme.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await controller.applyCoupon(_couponTextController.text);
                    _couponTextController.clear();
                  } catch (_) {}
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(80, 46),
                ),
                child: const Text(
                  AppStrings.apply,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Active Coupon Badge
          if (controller.couponCode.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.confirmation_num_outlined,
                  color: AppTheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  AppStrings.couponAppliedMsg(
                    controller.couponCode.value,
                    controller.discount.value,
                  ),
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          // Points Redemption Selector
          Obx(() {
            final rewardsController = Get.find<RewardsController>();
            final balance = rewardsController.pointsBalance.value;
            if (balance <= 0) return const SizedBox.shrink();

            final subtotal = controller.subtotal;
            final maxDiscount = subtotal * 0.5;
            final potentialDiscount = balance / 100.0;
            final appliedDiscount = potentialDiscount > maxDiscount ? maxDiscount : potentialDiscount;
            final pointsToRedeem = (appliedDiscount * 100).round();

            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.isPointsRedeemed.value
                      ? AppTheme.primary
                      : AppTheme.dividerColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: controller.isPointsRedeemed.value
                        ? AppTheme.primary
                        : AppTheme.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Redeem $pointsToRedeem Points',
                          style: TextStyle(
                            color: AppTheme.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Get \$${appliedDiscount.toStringAsFixed(2)} off your order (50% max)',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.isPointsRedeemed.value,
                    activeColor: AppTheme.primary,
                    activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
                    onChanged: (val) {
                      controller.isPointsRedeemed.value = val;
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 12),

          // 2. Price summary breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.subtotal,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              Text(
                '\$${controller.subtotal.toStringAsFixed(2)}',
                style: TextStyle(color: AppTheme.primaryText, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.discount,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              Text(
                '-\$${controller.discount.value.toStringAsFixed(2)}',
                style: TextStyle(color: AppTheme.discountColor, fontSize: 14),
              ),
            ],
          ),
          if (controller.pointsDiscount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Points Discount',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                Text(
                  '-\$${controller.pointsDiscount.toStringAsFixed(2)}',
                  style: TextStyle(color: AppTheme.discountColor, fontSize: 14),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.deliveryFee,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              Text(
                controller.deliveryFee == 0.0
                    ? AppStrings.freeShipping
                    : '\$${controller.deliveryFee.toStringAsFixed(2)}',
                style: TextStyle(
                  color: controller.deliveryFee == 0.0
                      ? AppTheme.primary
                      : AppTheme.primaryText,
                  fontSize: 14,
                  fontWeight: controller.deliveryFee == 0.0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalAmount,
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${controller.total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. Checkout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // Pass order arguments forward to checkout screen (Task 8)
                Get.toNamed(
                  '/checkout',
                  arguments: {
                    'items': controller.cartItems
                        .map((e) => e.toJson())
                        .toList(),
                    'subtotal': controller.subtotal,
                    'discount': controller.discount.value,
                    'pointsDiscount': controller.pointsDiscount,
                    'pointsConsumed': controller.pointsConsumed,
                    'deliveryFee': controller.deliveryFee,
                    'total': controller.total,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                AppStrings.proceedToCheckout,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty state screen ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return SkincareEmptyState(
      icon: Icons.shopping_bag_outlined,
      title: AppStrings.emptyCartTitle,
      description: AppStrings.emptyCartDesc,
      buttonText: AppStrings.shopBestSellers,
      onButtonPressed: () => Get.toNamed('/product-listing'),
    );
  }

  // ─── Shimmer loading state ────────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => const _CartItemSkeleton(),
    );
  }
}

// ─── Skeleton Item row ───────────────────────────────────────────────────────
class _CartItemSkeleton extends StatefulWidget {
  const _CartItemSkeleton();

  @override
  State<_CartItemSkeleton> createState() => _CartItemSkeletonState();
}

class _CartItemSkeletonState extends State<_CartItemSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.1, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 96,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
