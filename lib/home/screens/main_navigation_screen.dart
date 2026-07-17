import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import 'home_screen.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

class MainNavigationScreen extends StatelessWidget {
  MainNavigationScreen({super.key});

  final MainNavigationController controller = Get.put(
    MainNavigationController(),
  );

  final List<Widget> _pages = [
    HomeScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            IndexedStack(
              index: controller.selectedIndex.value,
              children: _pages,
            ),
            const Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SkincareCompareFloatingBar(),
            ),
          ],
        ),
        bottomNavigationBar: SkincareBottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
        ),
      ),
    );
  }
}
