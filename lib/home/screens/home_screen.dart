import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controllers/home_controller.dart';
import 'widgets/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Inject HomeController
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
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
            return _buildErrorState(message: "No content available");
          }

          return RefreshIndicator(
            onRefresh: homeController.fetchHomeData,
            color: const Color(0xFF8C6EFF),
            backgroundColor: const Color(0xFF130538),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  
                  // 1. Search Bar (tap-to-navigate)
                  _buildFakeSearchBar(),
                  const SizedBox(height: 24),
                  
                  // 2. Banner Carousel
                  BannerCarousel(banners: data.banners),
                  const SizedBox(height: 28),
                  
                  // 3. Categories
                  CategoryScrollList(categories: data.categories),
                  const SizedBox(height: 28),
                  
                  // 4. Best Sellers
                  ProductScrollList(title: "Best Sellers", products: data.bestSellers),
                  const SizedBox(height: 28),
                  
                  // 5. New Arrivals
                  ProductScrollList(title: "New Arrivals", products: data.newArrivals),
                  const SizedBox(height: 28),
                  
                  // 6. Skin Concern Section
                  SkinConcernGrid(concerns: data.skinConcerns),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Clear Skin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Start your daily skincare routine",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color.fromARGB(25, 255, 255, 255),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildFakeSearchBar() {
    return GestureDetector(
      onTap: () {
        // Tapping search redirects to Task 4 Product Listing with no pre-filled text
        Get.toNamed('/product-listing');
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(20, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(40, 140, 110, 255),
            width: 1,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.white54),
            SizedBox(width: 12),
            Text(
              "Search products, concerns...",
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              "Failed to Load Home Content",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? homeController.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: homeController.fetchHomeData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C6EFF),
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
