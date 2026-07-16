import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/comparison_controller.dart';
import '../app_colors.dart';
import '../app_strings.dart';

// ─── Reusable Skincare App Header ──────────────────────────────────────────
class SkincareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;

  const SkincareAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => Get.back(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ─── Reusable Skincare Bottom Action Panel (Bottom buttons in forms/checkouts) ──
class SkincareBottomActionPanel extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SkincareBottomActionPanel({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              disabledBackgroundColor: AppColor.buttonColor.withValues(alpha: 0.5),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Skincare Bottom Navigation Bar ─────────────────────────────────
class SkincareBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SkincareBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColor.backgroundColor,
      selectedItemColor: AppColor.primary,
      unselectedItemColor: AppColor.secondaryText,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.navHome,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: AppStrings.navWishlist,
        ),
        BottomNavigationBarItem(
          icon: Obx(() {
            final count = Get.find<CartController>().totalCartItems;
            return count > 0
                ? Badge(
                    label: Text('$count'),
                    backgroundColor: AppColor.primary,
                    child: const Icon(Icons.shopping_cart_outlined),
                  )
                : const Icon(Icons.shopping_cart_outlined);
          }),
          activeIcon: Obx(() {
            final count = Get.find<CartController>().totalCartItems;
            return count > 0
                ? Badge(
                    label: Text('$count'),
                    backgroundColor: AppColor.primary,
                    child: const Icon(Icons.shopping_cart),
                  )
                : const Icon(Icons.shopping_cart);
          }),
          label: AppStrings.navCart,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: AppStrings.navProfile,
        ),
      ],
    );
  }
}

// ─── Reusable Empty State Placeholder ───────────────────────────────────────
class SkincareEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const SkincareEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColor.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColor.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String mapDatabaseImagePath(String path) {
  if (path.isEmpty) return 'assets/images/cream.webp';
  if (path.startsWith('assets/')) return path;

  // Extract filename
  final filename = path.split('/').last.toLowerCase();

  switch (filename) {
    // Banners
    case 'banner1.jpg':
      return 'assets/images/cream.webp';
    case 'banner2.jpg':
      return 'assets/images/cream.webp';
    case 'banner3.jpg':
      return 'assets/images/cream2.jpg';

    // Categories / Products
    case 'serum.jpg':
    case 'vitamin-c-serum.jpg':
    case 'vitamin-c-face-serum.jpg':
    case 'niacinamide.jpg':
      return 'assets/images/Serum.jpg';

    case 'moisturizer.jpg':
    case 'nightcream.jpg':
    case 'night-repair-cream.jpg':
      return 'assets/images/moisturrizer2.webp';

    case 'sunscreen.jpg':
    case 'matte-spf.jpg':
    case 'matte-sunscreen-gel.jpg':
      return 'assets/images/moisturrizer3.jpeg';

    case 'cleanser.jpg':
    case 'facewash.jpg':
    case 'foaming-face-wash.jpg':
    case 'gentle-face-cleanser.jpg':
      return 'assets/images/moisturrizer4.webp';

    default:
      if (!path.startsWith('http') &&
          (path.endsWith('.jpg') ||
              path.endsWith('.png') ||
              path.endsWith('.webp') ||
              path.endsWith('.jpeg') ||
              path.endsWith('.avif'))) {
        return 'assets/images/cream.webp';
      }
      return path;
  }
}

ImageProvider getSkincareImageProvider(String path) {
  final mappedPath = mapDatabaseImagePath(path);
  if (mappedPath.startsWith('assets/')) {
    return AssetImage(mappedPath);
  }
  return CachedNetworkImageProvider(mappedPath);
}

Widget getSkincareImage(String path, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  final mappedPath = mapDatabaseImagePath(path);
  if (mappedPath.startsWith('assets/')) {
    return Image.asset(
      mappedPath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => Container(
        color: AppColor.primary.withValues(alpha: 0.15),
        child: const Icon(Icons.broken_image_outlined, color: Colors.white30),
      ),
    );
  }
  return CachedNetworkImage(
    imageUrl: mappedPath,
    fit: fit,
    width: width,
    height: height,
    placeholder: (_, __) => Container(color: AppColor.primary.withValues(alpha: 0.12)),
    errorWidget: (_, __, ___) => Container(
      color: AppColor.primary.withValues(alpha: 0.20),
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.white30,
      ),
    ),
  );
}

// ─── Floating Product Compare Action Bar ─────────────────────────────────────
class SkincareCompareFloatingBar extends StatelessWidget {
  const SkincareCompareFloatingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ComparisonController comparisonController =
        Get.find<ComparisonController>();

    return Obx(() {
      final count = comparisonController.comparedIds.length;
      if (count == 0) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed('/product-comparison'),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColor.primary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withValues(alpha: 0.20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.balance,
                color: AppColor.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Compare ($count / 3)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // "View" link
              Text(
                'View',
                style: TextStyle(
                  color: AppColor.buttonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              const VerticalDivider(
                color: Colors.white24,
                indent: 14,
                endIndent: 14,
                width: 1,
              ),
              const SizedBox(width: 8),
              // Clear action
              GestureDetector(
                onTap: () => comparisonController.clearComparison(),
                child: const Icon(
                  Icons.close,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
