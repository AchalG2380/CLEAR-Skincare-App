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
import 'core/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register AuthController globally so it maintains state across all screens
  Get.put(AuthController(), permanent: true);

  // Register WishlistController globally so it coordinates wishlist state app-wide
  Get.put(WishlistController(), permanent: true);

  // Register CartController globally so it coordinates cart state app-wide
  Get.put(CartController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Clear",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.backgroundColor,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          surface: AppColor.surface,
          brightness: Brightness.dark,
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
        GetPage(name: '/checkout-payment', page: () => CheckoutPaymentScreen()),
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
      ],
    );
  }
}
