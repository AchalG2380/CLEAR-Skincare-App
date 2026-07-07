import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Betrhealth",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(39, 22, 67, 1.0),
        ),
        fontFamily: 'MontserratAlternates',
      ),
      home: const SplashScreen(),
    );
  }
}
