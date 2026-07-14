import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/home_response_model.dart';
import '../../data/models/product_model.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_strings.dart';
import '../../../../core/widgets/product_widgets.dart';
import '../../../../core/widgets/app_widgets.dart';

// --- Pulseless / Animated Pulse Skeleton Shimmer Loader ---
class HomeShimmer extends StatefulWidget {
  const HomeShimmer({super.key});

  @override
  State<HomeShimmer> createState() => _HomeShimmerState();
}

class _HomeShimmerState extends State<HomeShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.15, end: 0.4).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Search bar skeleton
        _skeletonBox(width: double.infinity, height: 50),
        const SizedBox(height: 20),

        // Banner carousel skeleton
        _skeletonBox(width: double.infinity, height: 180, borderRadius: 16),
        const SizedBox(height: 24),

        // Categories title skeleton
        _skeletonBox(width: 120, height: 20),
        const SizedBox(height: 12),

        // Categories horizontal list skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return Column(
              children: [
                _skeletonBox(width: 65, height: 65, borderRadius: 32.5),
                const SizedBox(height: 8),
                _skeletonBox(width: 55, height: 10),
              ],
            );
          }),
        ),
        const SizedBox(height: 32),

        // Best sellers title skeleton
        _skeletonBox(width: 120, height: 20),
        const SizedBox(height: 16),

        // Best sellers cards skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(2, (index) {
            return _skeletonBox(width: 160, height: 220, borderRadius: 16);
          }),
        ),
      ],
    );
  }
}

// --- Banner Carousel with Dots Indicator & Auto-Play ---
class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.banners.isEmpty || !mounted) return;
      int nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              // Restart auto-timer on swipe override
              _startTimer();
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () {
                  if (banner.productActionId != null) {
                    Get.toNamed(
                      '/product-details',
                      arguments: banner.productActionId,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: getSkincareImageProvider(banner.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            final isSelected = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isSelected ? 20 : 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColor.primary
                    : AppColor.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// --- Horizontal Categories Scroll Row ---
class CategoryScrollList extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryScrollList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.categories,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    '/product-listing',
                    arguments: {'category': category.id},
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.cardBackground,
                          border: Border.all(
                            color: AppColor.primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          image: DecorationImage(
                            image: getSkincareImageProvider(category.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Horizontal Reusable Products Scroll List ---
class ProductScrollList extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const ProductScrollList({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 270, // Expanded height fits text and stars perfectly
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 155,
                  child: ProductCard(product: product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Circular Skin Concerns Grid ---
class SkinConcernGrid extends StatelessWidget {
  final List<ConcernModel> concerns;

  const SkinConcernGrid({super.key, required this.concerns});

  @override
  Widget build(BuildContext context) {
    if (concerns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.shopConcerns,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: concerns.length,
          itemBuilder: (context, index) {
            final concern = concerns[index];
            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  '/product-listing',
                  arguments: {'concern': concern.name},
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.cardBackground,
                        border: Border.all(
                          color: AppColor.primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        image: DecorationImage(
                          image: getSkincareImageProvider(concern.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    concern.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// --- Skin Type Quiz CTA Banner ---
class SkinQuizBanner extends StatelessWidget {
  const SkinQuizBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed('/skin-quiz'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary.withValues(alpha: 0.18),
              AppColor.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.primary.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.spa_outlined,
                color: AppColor.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not sure about your skin type?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Take our 5-question quiz for personalized picks',
                    style: TextStyle(color: AppColor.textMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColor.textDim,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
