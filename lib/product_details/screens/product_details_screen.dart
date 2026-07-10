import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/product_details_controller.dart';
import '../data/models/product_details_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key});

  final ProductDetailsController controller = Get.put(
    ProductDetailsController(),
  );
  final WishlistController wishlistController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
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
                              const Text(
                                AppStrings.clearSkincare,
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColor.ratingStar,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${details.rating}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' (${details.reviews.length} ${AppStrings.ratingReviewsSuffix})',
                                    style: const TextStyle(
                                      color: Colors.white38,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '\$${details.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColor.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            details.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.white10),
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
                              style: const TextStyle(
                                color: Colors.white70,
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
                                          const Icon(
                                            Icons.check_circle_outline,
                                            color: AppColor.primary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              b,
                                              style: const TextStyle(
                                                color: Colors.white70,
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
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.white10),
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
          ],
        );
      }),
    );
  }

  // ─── Pinned AppBar ────────────────────────────────────────────────────────
  Widget _buildPinnedAppBar(ProductDetailsModel details) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColor.backgroundColor.withValues(alpha: 0.78), Colors.transparent],
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              Obx(() {
                final isWish = wishlistController.isWishlisted(details.id);
                return IconButton(
                  icon: Icon(
                    isWish ? Icons.favorite : Icons.favorite_border,
                    color: isWish ? AppColor.favoriteActive : Colors.white,
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
              return CachedNetworkImage(
                imageUrl: details.imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) =>
                    Container(color: AppColor.primary.withValues(alpha: 0.12)),
                errorWidget: (_, __, ___) => Container(
                  color: AppColor.primary.withValues(alpha: 0.16),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white30,
                      size: 50,
                    ),
                  ),
                ),
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
                          ? AppColor.primary
                          : Colors.white30,
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
          const Text(
            AppStrings.customerReviews,
            style: TextStyle(
              color: Colors.white,
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
                color: AppColor.cardBackground,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        rev.date,
                        style: const TextStyle(
                          color: Colors.white30,
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
                            ? AppColor.ratingStar
                            : AppColor.dividerColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rev.comment,
                    style: const TextStyle(
                      color: Colors.white70,
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
      decoration: const BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Stepper Quantity Selector
          Container(
            decoration: BoxDecoration(
              color: AppColor.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.dividerColor.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                  onPressed: controller.decrementQuantity,
                ),
                Obx(
                  () => Text(
                    '${controller.quantity.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
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
                  backgroundColor: AppColor.buttonColor,
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
    return const Center(
      child: CircularProgressIndicator(color: AppColor.primary),
    );
  }

  // ─── Error Screen ──────────────────────────────────────────────────────────
  Widget _buildErrorState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColor.error, size: 50),
          const SizedBox(height: 16),
          Text(
            message ?? controller.errorMessage.value,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Back to Shop'),
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
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColor.primary,
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
