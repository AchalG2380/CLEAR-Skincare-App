import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/app_widgets.dart';
import '../../home/data/models/product_model.dart';
import '../controllers/wishlist_controller.dart';

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  final WishlistController controller = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Text(
          AppStrings.wishlistTitle,
          style: TextStyle(
            color: AppTheme.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value &&
                controller.wishlistItems.isEmpty) {
              return _buildShimmerLoading();
            }

            if (controller.wishlistItems.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: controller.fetchWishlist,
              color: AppTheme.primary,
              backgroundColor: AppTheme.backgroundColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = controller.wishlistItems[index];
                  return _buildWishlistItem(product);
                },
              ),
            );
          }),
          const Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SkincareCompareFloatingBar(),
          ),
        ],
      ),
    ));
  }

  // ─── Individual Wishlist Item Row ──────────────────────────────────────────
  Widget _buildWishlistItem(ProductModel product) {
    return Dismissible(
      key: Key('wishlist_${product.id}'),
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
        controller.toggleWishlist(product);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 1. Product Image
            GestureDetector(
              onTap: () =>
                  Get.toNamed('/product-details', arguments: product.id),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: getSkincareImage(product.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 2. Product Name, Rating, and Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () =>
                        Get.toNamed('/product-details', arguments: product.id),
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.ratingStar, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 3. Action Buttons (Move to Cart & Delete)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 22,
                  ),
                  onPressed: () => controller.toggleWishlist(product),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => controller.moveToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    AppStrings.addToCart,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return SkincareEmptyState(
      icon: Icons.favorite_border,
      title: AppStrings.emptyWishlistTitle,
      description: AppStrings.emptyWishlistDesc,
      buttonText: AppStrings.exploreProducts,
      onButtonPressed: () => Get.toNamed('/product-listing'),
    );
  }

  // ─── Shimmer Loading State ────────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (_, __) => const _WishlistItemSkeleton(),
    );
  }
}

// ─── Skeleton Item row ───────────────────────────────────────────────────────
class _WishlistItemSkeleton extends StatefulWidget {
  const _WishlistItemSkeleton();

  @override
  State<_WishlistItemSkeleton> createState() => _WishlistItemSkeletonState();
}

class _WishlistItemSkeletonState extends State<_WishlistItemSkeleton>
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
        height: 104,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
