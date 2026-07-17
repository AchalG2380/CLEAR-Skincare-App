import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth/controllers/auth_controller.dart';
import 'auth/screens/forgot_password_screen.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/reset_password_screen.dart';
import 'auth/screens/verify_otp_screen.dart';
import 'home/screens/main_navigation_screen.dart';
import 'onboarding/screens/onboarding_screen.dart';
import 'onboarding/screens/splash_screen.dart';
import 'product_listing/screens/product_listing_screen.dart';
import 'wishlist/controllers/wishlist_controller.dart';
import 'cart/controllers/cart_controller.dart';
import 'product_details/screens/product_details_screen.dart';
import 'checkout/screens/checkout_address_screen.dart';
import 'checkout/screens/checkout_payment_screen.dart';
import 'checkout/screens/checkout_review_screen.dart';
import 'checkout/screens/checkout_success_screen.dart';
import 'orders/screens/order_list_screen.dart';
import 'orders/screens/order_details_screen.dart';
import 'profile/screens/edit_profile_screen.dart';
import 'profile/screens/change_password_screen.dart';
import 'profile/screens/my_addresses_screen.dart';
import 'skin_quiz/screens/skin_quiz_screen.dart';
import 'core/app_theme.dart';
import 'core/theme_controller.dart';
import 'core/controllers/comparison_controller.dart';
import 'product_comparison/screens/comparison_screen.dart';
import 'routine_planner/screens/routine_planner_screen.dart';
import 'core/controllers/rewards_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register ThemeController first — AppTheme relies on Get.find() for it,
  // so it must exist before any screen reads a color.
  Get.put(ThemeController(), permanent: true);

  // Register AuthController globally so it maintains state across all screens
  Get.put(AuthController(), permanent: true);

  // Register WishlistController globally so it coordinates wishlist state app-wide
  Get.put(WishlistController(), permanent: true);

  // Register CartController globally so it coordinates cart state app-wide
  Get.put(CartController(), permanent: true);

  // Register ComparisonController globally so it coordinates comparison state app-wide
  Get.put(ComparisonController(), permanent: true);

  // Register RewardsController globally so it coordinates reward points state app-wide
  Get.put(RewardsController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole MaterialApp theme when ThemeController toggles —
    // this is the one place a full-app Obx wrap is appropriate, since
    // theme affects every descendant.
    return Obx(() {
      return GetMaterialApp(
        title: "Clear",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primary,
            primary: AppTheme.primary,
            secondary: AppTheme.secondary,
            surface: AppTheme.surface,
            brightness: Get.find<ThemeController>().isDarkMode.value
                ? Brightness.dark
                : Brightness.light,
          ),
        ),
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const SplashScreen()),
          GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/register', page: () => const RegisterScreen()),
          GetPage(
            name: '/forgot-password',
            page: () => const ForgotpasswordScreen(),
          ),
          GetPage(name: '/verify-otp', page: () => const VerifyOTPScreen()),
          GetPage(
            name: '/reset-password',
            page: () => const ResetPasswordScreen(),
          ),
          // '/home' route now returns the navigation shell holding the bottom bar
          GetPage(name: '/home', page: () => MainNavigationScreen()),

          GetPage(name: '/product-listing', page: () => ProductListingScreen()),
          GetPage(name: '/product-details', page: () => ProductDetailsScreen()),
          GetPage(name: '/checkout', page: () => CheckoutAddressScreen()),
          GetPage(
            name: '/checkout-payment',
            page: () => CheckoutPaymentScreen(),
          ),
          GetPage(name: '/checkout-review', page: () => CheckoutReviewScreen()),
          GetPage(
            name: '/checkout-success',
            page: () => const CheckoutSuccessScreen(),
          ),
          GetPage(name: '/orders', page: () => OrderListScreen()),
          GetPage(name: '/order-details', page: () => OrderDetailsScreen()),
          GetPage(name: '/edit-profile', page: () => EditProfileScreen()),
          GetPage(name: '/change-password', page: () => ChangePasswordScreen()),
          GetPage(name: '/my-addresses', page: () => MyAddressesScreen()),
          GetPage(name: '/skin-quiz', page: () => SkinQuizScreen()),
          GetPage(
            name: '/product-comparison',
            page: () => const ComparisonScreen(),
          ),
          GetPage(
            name: '/routine-planner',
            page: () => RoutinePlannerScreen(),
          ),
        ],
      );
    });
  }
}
