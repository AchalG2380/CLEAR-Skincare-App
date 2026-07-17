import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/app_widgets.dart';
import '../controllers/orders_controller.dart';
import '../data/models/order_model.dart';

class OrderListScreen extends StatelessWidget {
  OrderListScreen({super.key});

  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const SkincareAppBar(title: AppStrings.myOrdersTitle),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return _buildShimmerLoading();
        }

        if (controller.orders.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchOrders,
          color: AppTheme.primary,
          backgroundColor: AppTheme.backgroundColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderRowCard(order);
            },
          ),
        );
      }),
    );
  }

  // ─── Individual Order Row Card ─────────────────────────────────────────────
  Widget _buildOrderRowCard(OrderModel order) {
    return GestureDetector(
      onTap: () => Get.toNamed('/order-details', arguments: order.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.date.split(',')[0], // Just date part
                  style: TextStyle(color: AppTheme.textDark, fontSize: 12),
                ),
              ],
            ),
            Divider(color: AppTheme.dividerColor, height: 24),

            // Item Previews (Thumbnails & Quantities)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: order.items.length,
                      itemBuilder: (context, idx) {
                        final item = order.items[idx];
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.dividerColor),
                            image: DecorationImage(
                              image: getSkincareImageProvider(
                                item.product.imageUrl,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  order.items.fold<int>(
                            0,
                            (sum, item) => sum + item.quantity,
                          ) ==
                          1
                      ? AppStrings.oneItemText
                      : '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} ${AppStrings.itemsText}',
                  style: TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pricing & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Status Badge Widget ────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'delivered':
        bgColor = AppTheme.successBg.withValues(alpha: 0.2);
        textColor = AppTheme.success;
        break;
      case 'shipped':
        bgColor = AppTheme.warningBg.withValues(alpha: 0.2);
        textColor = AppTheme.warning;
        break;
      case 'processing':
        bgColor = AppTheme.infoBg.withValues(alpha: 0.2);
        textColor = AppTheme.info;
        break;
      case 'cancelled':
        bgColor = AppTheme.errorBg.withValues(alpha: 0.2);
        textColor = AppTheme.error;
        break;
      default:
        bgColor = AppTheme.infoBg.withValues(alpha: 0.2);
        textColor = AppTheme.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Empty state for orders history ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return SkincareEmptyState(
      icon: Icons.receipt_long_outlined,
      title: AppStrings.emptyOrdersTitle,
      description: AppStrings.emptyOrdersDesc,
      buttonText: AppStrings.shopProducts,
      onButtonPressed: () => Get.offAllNamed('/home'),
    );
  }

  // ─── Shimmer skeletons for loading state ────────────────────────────────────
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => const _OrderSkeletonItem(),
    );
  }
}

// ─── Animated Shimmer Skeleton Item card ─────────────────────────────────────
class _OrderSkeletonItem extends StatefulWidget {
  const _OrderSkeletonItem();

  @override
  State<_OrderSkeletonItem> createState() => _OrderSkeletonItemState();
}

class _OrderSkeletonItemState extends State<_OrderSkeletonItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.1, end: 0.35).animate(_ctrl);
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
        height: 154,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
