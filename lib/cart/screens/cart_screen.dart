import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/product_widgets.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController controller = Get.find<CartController>();
  final TextEditingController _couponTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        title: const Text(
          AppStrings.cartTitle,
          style: TextStyle(
            color: Colors.white,
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
          color: AppColor.primary,
          backgroundColor: AppColor.backgroundColor,
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
          color: AppColor.error.withValues(alpha: 0.8),
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
      decoration: const BoxDecoration(
        color: AppColor.backgroundColor,
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
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    cursorColor: AppColor.primary,
                    decoration: InputDecoration(
                      hintText: AppStrings.hintCoupon,
                      hintStyle: const TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: AppColor.inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColor.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColor.primary),
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
                  backgroundColor: AppColor.buttonColor,
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
                const Icon(
                  Icons.confirmation_num_outlined,
                  color: AppColor.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  AppStrings.couponAppliedMsg(controller.couponCode.value, controller.discount.value),
                  style: const TextStyle(
                    color: AppColor.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // 2. Price summary breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.subtotal,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                '\$${controller.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.discount,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                '-\$${controller.discount.value.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColor.discountColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.deliveryFee,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                controller.deliveryFee == 0.0
                    ? AppStrings.freeShipping
                    : '\$${controller.deliveryFee.toStringAsFixed(2)}',
                style: TextStyle(
                  color: controller.deliveryFee == 0.0
                      ? AppColor.primary
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: controller.deliveryFee == 0.0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.totalAmount,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${controller.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColor.primary,
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
                    'deliveryFee': controller.deliveryFee,
                    'total': controller.total,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonColor,
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
          color: AppColor.primary.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
