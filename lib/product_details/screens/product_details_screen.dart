import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../../core/widgets/app_widgets.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../core/controllers/comparison_controller.dart';
import '../controllers/product_details_controller.dart';
import '../data/models/product_details_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key});

  final ProductDetailsController controller = Get.put(
    ProductDetailsController(),
  );
  final WishlistController wishlistController = Get.find<WishlistController>();
  final ComparisonController comparisonController = Get.find<ComparisonController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.hasError.value) {
          return _buildErrorState();
        }

        final details = controller.productDetails.value;
        if (details == null) {
          return _buildErrorState(message: 'Product details unavailable.');
        }

        return Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 88,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Swipeable Image Carousel
                    _buildImageCarousel(context, details),

                    // 2. Information Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.clearSkincare,
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppTheme.ratingStar,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${details.rating}',
                                    style: TextStyle(
                                      color: AppTheme.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' (${details.reviews.length} ${AppStrings.ratingReviewsSuffix})',
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details.name,
                            style: TextStyle(
                              color: AppTheme.primaryText,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                '\$${details.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Obx(() {
                                final isCompare = comparisonController.isCompared(details.id);
                                return OutlinedButton.icon(
                                  onPressed: () => comparisonController.toggleCompare(details.id),
                                  icon: Icon(
                                    isCompare ? Icons.balance : Icons.balance_outlined,
                                    size: 16,
                                    color: isCompare ? AppTheme.primary : AppTheme.secondaryText,
                                  ),
                                  label: Text(
                                    isCompare ? 'Compared' : 'Add to Compare',
                                    style: TextStyle(
                                      color: isCompare ? AppTheme.primary : AppTheme.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isCompare ? AppTheme.primary : AppTheme.dividerColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            details.description,
                            style: TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: AppTheme.dividerColor),
                    ),

                    // 3. Expandable Text Accordions
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _ExpandableSection(
                            title: AppStrings.ingredients,
                            content: Text(
                              details.ingredients,
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                          _ExpandableSection(
                            title: AppStrings.benefits,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: details.benefits
                                  .map(
                                    (b) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: AppTheme.primary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              b,
                                              style: TextStyle(
                                                color: AppTheme.secondaryText,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          _ExpandableSection(
                            title: AppStrings.howToUse,
                            content: Text(
                              details.usage,
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: AppTheme.dividerColor),
                    ),

                    // 4. Customer Reviews
                    _buildReviewsSection(details),
                  ],
                ),
              ),
            ),

            // Pinned AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildPinnedAppBar(details),
            ),

            // Pinned Bottom Action Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStickyActionBar(details),
            ),
            const Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: SkincareCompareFloatingBar(),
            ),
          ],
        );
      }),
    ));
  }

  // ─── Pinned AppBar ────────────────────────────────────────────────────────
  Widget _buildPinnedAppBar(ProductDetailsModel details) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundColor.withValues(alpha: 0.78), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
                onPressed: () => Get.back(),
              ),
              Obx(() {
                final isWish = wishlistController.isWishlisted(details.id);
                return IconButton(
                  icon: Icon(
                    isWish ? Icons.favorite : Icons.favorite_border,
                    color: isWish ? AppTheme.favoriteActive : AppTheme.primaryText,
                  ),
                  onPressed: () => controller.toggleWishlist(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Image Carousel ────────────────────────────────────────────────────────
  Widget _buildImageCarousel(
    BuildContext context,
    ProductDetailsModel details,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.45,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: details.imageUrls.length,
            onPageChanged: controller.updateImageIndex,
            itemBuilder: (context, index) {
              return getSkincareImage(
                details.imageUrls[index],
                fit: BoxFit.contain,
                width: double.infinity,
              );
            },
          ),
          // Indicator Dots
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                details.imageUrls.length,
                (index) => Obx(
                  () => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: controller.selectedImageIndex.value == index
                        ? 20
                        : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.selectedImageIndex.value == index
                          ? AppTheme.primary
                          : AppTheme.textDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reviews Section ───────────────────────────────────────────────────────
  Widget _buildReviewsSection(ProductDetailsModel details) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.customerReviews,
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...details.reviews.map(
            (rev) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rev.reviewerName,
                        style: TextStyle(
                          color: AppTheme.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        rev.date,
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (starIdx) => Icon(
                        Icons.star,
                        size: 14,
                        color: starIdx < rev.rating
                            ? AppTheme.ratingStar
                            : AppTheme.dividerColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rev.comment,
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sticky Action Bar (Cart Stepper & Add to Cart) ────────────────────────
  Widget _buildStickyActionBar(ProductDetailsModel details) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Stepper Quantity Selector
          Container(
            decoration: BoxDecoration(
              color: AppTheme.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.dividerColor.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: AppTheme.primaryText, size: 18),
                  onPressed: controller.decrementQuantity,
                ),
                Obx(
                  () => Text(
                    '${controller.quantity.value}',
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppTheme.primaryText, size: 18),
                  onPressed: controller.incrementQuantity,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Add to Cart Button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: controller.addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  AppStrings.addToCart,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Loading Skeleton / Shimmer ────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return Center(
      child: CircularProgressIndicator(color: AppTheme.primary),
    );
  }

  // ─── Error Screen ──────────────────────────────────────────────────────────
  Widget _buildErrorState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppTheme.error, size: 50),
          const SizedBox(height: 16),
          Text(
            message ?? controller.errorMessage.value,
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.backToShop),
          ),
        ],
      ),
    );
  }
}

// ─── Expandable Section Widget ───────────────────────────────────────────────
class _ExpandableSection extends StatefulWidget {
  final String title;
  final Widget content;

  const _ExpandableSection({required this.title, required this.content});

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: TextStyle(
                color: AppTheme.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppTheme.primary,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.content,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
