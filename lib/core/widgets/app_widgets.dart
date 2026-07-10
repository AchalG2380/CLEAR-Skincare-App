import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cart/controllers/cart_controller.dart';

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
      backgroundColor: const Color(0xFF130538),
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
        color: Color(0xFF130538),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C6EFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              disabledBackgroundColor: const Color(
                0xFF8C6EFF,
              ).withValues(alpha: 0.5),
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
      backgroundColor: const Color(0xFF130538),
      selectedItemColor: const Color(0xFF8C6EFF),
      unselectedItemColor: const Color.fromARGB(150, 255, 255, 255),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Obx(() {
            final count = Get.find<CartController>().totalCartItems;
            return count > 0
                ? Badge(
                    label: Text('$count'),
                    backgroundColor: const Color(0xFF8C6EFF),
                    child: const Icon(Icons.shopping_cart_outlined),
                  )
                : const Icon(Icons.shopping_cart_outlined);
          }),
          activeIcon: Obx(() {
            final count = Get.find<CartController>().totalCartItems;
            return count > 0
                ? Badge(
                    label: Text('$count'),
                    backgroundColor: const Color(0xFF8C6EFF),
                    child: const Icon(Icons.shopping_cart),
                  )
                : const Icon(Icons.shopping_cart);
          }),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
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
                color: Color.fromARGB(15, 255, 255, 255),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: const Color(0xFFC7B6FF)),
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
                    backgroundColor: const Color(0xFF8C6EFF),
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
