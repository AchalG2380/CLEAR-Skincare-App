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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register AuthController globally so it maintains state across all screens
  Get.put(AuthController(), permanent: true);

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
        
        // Mock targets for Task 4 & Task 5 transitions
        GetPage(
          name: '/product-listing', 
          page: () => Scaffold(
            appBar: AppBar(backgroundColor: const Color(0xFF130538), leading: const BackButton(color: Colors.white)),
            backgroundColor: const Color(0xFF0E0544),
            body: const Center(child: Text("Product Listing Screen (Task 4)", style: TextStyle(color: Colors.white, fontSize: 16))),
          )
        ),
        GetPage(
          name: '/product-details', 
          page: () => Scaffold(
            appBar: AppBar(backgroundColor: const Color(0xFF130538), leading: const BackButton(color: Colors.white)),
            backgroundColor: const Color(0xFF0E0544),
            body: const Center(child: Text("Product Details Screen (Task 5)", style: TextStyle(color: Colors.white, fontSize: 16))),
          )
        ),
      ],
    );
  }
}
