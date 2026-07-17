import 'package:flutter/material.dart';
import '../../home/data/models/product_model.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import 'package:get/get.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/comparison_controller.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import 'app_widgets.dart';

// ─── Reusable Product Card Widget ───────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();
    final CartController cartController = Get.find<CartController>();
    final ComparisonController comparisonController =
        Get.find<ComparisonController>();

    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-details', arguments: product.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: getSkincareImage(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() {
                    final isWish = wishlistController.isWishlisted(product.id);
                    return GestureDetector(
                      onTap: () => wishlistController.toggleWishlist(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor.withValues(
                            alpha: 0.60,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWish ? Icons.favorite : Icons.favorite_border,
                          color: isWish
                              ? AppTheme.favoriteActive
                              : AppTheme.secondaryText,
                          size: 18,
                        ),
                      ),
                    );
                  }),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Obx(() {
                    final isCompare = comparisonController.isCompared(
                      product.id,
                    );
                    return GestureDetector(
                      onTap: () =>
                          comparisonController.toggleCompare(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor.withValues(
                            alpha: 0.60,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompare ? Icons.balance : Icons.balance_outlined,
                          color: isCompare ? AppTheme.primary : AppTheme.secondaryText,
                          size: 18,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.ratingStar, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 11,
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
                  const SizedBox(height: 6),
                  Obx(() {
                    final int cartQty = cartController.getProductQuantity(
                      product.id,
                    );
                    if (cartQty > 0) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                           IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.remove,
                              color: AppTheme.primaryText,
                              size: 20,
                            ),
                            onPressed: () =>
                                cartController.updateQuantity(product.id, -1),
                          ),
                          Text(
                            '$cartQty',
                            style: TextStyle(
                              color: AppTheme.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.add,
                              color: AppTheme.primaryText,
                              size: 20,
                            ),
                            onPressed: () =>
                                cartController.updateQuantity(product.id, 1),
                          ),
                        ],
                      );
                    } else {
                      return SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => cartController.addToCart(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.buttonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            AppStrings.addToCart,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Cart Item Row ────────────────────────────────────────────────
class SkincareCartItemRow extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final bool isEditable;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  const SkincareCartItemRow({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.isEditable = false,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 65,
              height: 65,
              child: getSkincareImage(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isEditable) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.quantityLabel}: $quantity',
                    style: TextStyle(color: AppTheme.textDark, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isEditable)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (onRemove != null)
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppTheme.error,
                      size: 20,
                    ),
                    onPressed: onRemove,
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onDecrement,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: AppTheme.primaryText,
                            size: 16,
                          ),
                        ),
                      ),
                      Text(
                        '$quantity',
                        style: TextStyle(
                          color: AppTheme.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: onIncrement,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Icon(Icons.add, color: AppTheme.primaryText, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Text(
              '\$${(price * quantity).toStringAsFixed(2)}',
              style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ));
  }
}
