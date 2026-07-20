import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_strings.dart';
import '../controllers/home_controller.dart';
import 'widgets/home_widgets.dart';
import '../../core/controllers/recently_viewed_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Inject HomeController
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (homeController.isLoading.value) {
              return const SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: HomeShimmer(),
              );
            }

          if (homeController.hasError.value) {
            return _buildErrorState();
          }

          final data = homeController.homeData.value;
          if (data == null) {
            return _buildErrorState(message: AppStrings.noContentAvailable);
          }

          return RefreshIndicator(
            onRefresh: homeController.fetchHomeData,
            color: AppTheme.primary,
            backgroundColor: AppTheme.backgroundColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.homeTitle,
                            style: TextStyle(
                              color: AppTheme.primaryText,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.homeSubtitle,
                            style: TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Search Bar (tap-to-navigate)
                  GestureDetector(
                    onTap: () => Get.toNamed('/product-listing'),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppTheme.textMuted),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.searchHint,
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Banner Carousel
                  BannerCarousel(banners: data.banners),
                  const SizedBox(height: 28),

                  // 3. Categories
                  CategoryScrollList(categories: data.categories),
                  const SizedBox(height: 28),

                  // 4. Best Sellers
                  ProductScrollList(
                    title: AppStrings.bestSellers,
                    products: data.bestSellers,
                  ),
                  const SizedBox(height: 28),

                  // 5. New Arrivals
                  ProductScrollList(
                    title: AppStrings.newArrivals,
                    products: data.newArrivals,
                  ),
                  const SizedBox(height: 28),

                  // Recently Viewed
                  Obx(() {
                    final rvController = Get.find<RecentlyViewedController>();
                    if (rvController.recentlyViewedProducts.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        ProductScrollList(
                          title: 'Recently Viewed',
                          products: rvController.recentlyViewedProducts,
                          trailing: GestureDetector(
                            onTap: () => rvController.clearHistory(),
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    );
                  }),

                  // 6. Skin Type Quiz CTA
                  SkinQuizBanner(),
                  const SizedBox(height: 16),

                  // AI Skin Analysis CTA
                  SkinAnalysisBanner(),
                  const SizedBox(height: 24),

                  // 7. Skin Concern Section
                  SkinConcernGrid(concerns: data.skinConcerns),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    ));
  }

  Widget _buildErrorState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 64),
            const SizedBox(height: 16),
            Text(
              AppStrings.homeLoadError,
              style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? homeController.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: homeController.fetchHomeData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  AppStrings.retry,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
