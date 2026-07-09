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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(14, 5, 68, 1),
        ),
        fontFamily: 'MontserratAlternates',
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
        
        GetPage(
          name: '/product-listing',
          page: () => ProductListingScreen(),
        ),
        GetPage(
          name: '/product-details',
          page: () => ProductDetailsScreen(),
        ),
      ],
    );
  }
}
