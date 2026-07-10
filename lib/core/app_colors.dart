import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // Core Theme Colors
  static const Color primary = Color.fromRGBO(6, 182, 212, 1);
  static const Color secondary = Color.fromRGBO(148, 163, 184, 1);
  static const Color backgroundColor = Color.fromRGBO(11, 19, 36, 1);
  static const Color surface = Color.fromRGBO(28, 41, 66, 1);
  static const Color buttonColor = Color.fromRGBO(60, 150, 160, 1);

  // Text Colors
  static const Color primaryText = Color.fromRGBO(255, 255, 255, 1);
  static const Color secondaryText = Color.fromRGBO(203, 213, 225, 1);
  static const Color titleColor = Color.fromRGBO(174, 179, 203, 1);
  static const Color textMuted = Color.fromRGBO(255, 255, 255, 0.7); // Colors.white70
  static const Color textDim = Color.fromRGBO(255, 255, 255, 0.54); // Colors.white54
  static const Color textDark = Color.fromRGBO(255, 255, 255, 0.38); // Colors.white38
  static const Color textHint = Color.fromRGBO(255, 255, 255, 0.3); // Colors.white30

  // Semantic Status Colors
  static const Color success = Color(0xFF81C784);
  static const Color successBg = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningBg = Color(0xFFEF6C00);
  static const Color error = Color(0xFFE57373);
  static const Color errorBg = Color(0xFFC62828);
  static const Color info = Color(0xFFE0E0E0);
  static const Color infoBg = Color(0xFF616161);
  static const Color discountColor = Color(0xFFFF8C8C);

  // Common UI Elements Colors
  static const Color dividerColor = Color.fromRGBO(255, 255, 255, 0.1); // Colors.white10
  static const Color cardBackground = Color.fromRGBO(255, 255, 255, 0.06); // Color.fromARGB(15, 255, 255, 255)
  static const Color inputFill = Color.fromRGBO(255, 255, 255, 0.06); // Color.fromARGB(15, 255, 255, 255)

  // App Feature & Rating Colors
  static const Color ratingStar = Color(0xFFFFC107); // Colors.amber
  static const Color favoriteActive = Color(0xFFFF5252); // Colors.redAccent
  static const Color freeShipping = Color(0xFF4CAF50); // Colors.green
}
