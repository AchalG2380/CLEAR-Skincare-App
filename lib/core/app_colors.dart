import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // Core Theme Colors (Cyberpunk Mint & Shadow Navy)
  static const Color primary = Color(0xFF00F5D4); // Neon Mint Green
  static const Color secondary = Color(0xFF8A99AD); // Cool Steel Slate
  static const Color backgroundColor = Color(0xFF090C15); // Dark Shadow Navy
  static const Color surface = Color(0xFF151B2E); // Deep Surface Steel
  static const Color buttonColor = Color(0xFF00BBF9); // Deep Sky Blue

  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFCBD5E1);
  static const Color titleColor = Color(0xFFAEB3C9);
  static const Color textMuted = Color(0xB3FFFFFF); // White70
  static const Color textDim = Color(0x8AFFFFFF); // White54
  static const Color textDark = Color(0x61FFFFFF); // White38
  static const Color textHint = Color(0x4DFFFFFF); // White30

  // Semantic Status Colors
  static const Color success = Color(0xFF00E676);
  static const Color successBg = Color(0xFF1B5E20);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningBg = Color(0xFFE65100);
  static const Color error = Color(0xFFFF5252);
  static const Color errorBg = Color(0xFFB71C1C);
  static const Color info = Color(0xFF29B6F6);
  static const Color infoBg = Color(0xFF01579B);
  static const Color discountColor = Color(0xFFFF5252);

  // Common UI Elements Colors
  static const Color dividerColor = Color(
    0x1FFFFFFF,
  ); // Light transparent white divider
  static const Color cardBackground = Color(0xFF151B2E); // Matches surface
  static const Color inputFill = Color(
    0xFF0F1424,
  ); // Darker steel for input fills

  // App Feature & Rating Colors
  static const Color ratingStar = Color(0xFFFFD700); // Gold star
  static const Color favoriteActive = Color(0xFFFF2A6D); // Neon pink favorite
  static const Color freeShipping = Color(0xFF00E676); // Matches success
}

class AppColorLight {
  AppColorLight._();

  static const Color primary = Color(
    0xFF00A896,
  ); // Deeper mint, readable on white
  static const Color secondary = Color(0xFF5C6B7A);
  static const Color backgroundColor = Color.fromARGB(255, 232, 235, 239);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFF0091D5);

  static const Color primaryText = Color(0xFF12141C);
  static const Color secondaryText = Color(0xFF4B5563);
  static const Color titleColor = Color(0xFF334155);
  static const Color textMuted = Color(0xB312141C);
  static const Color textDim = Color(0x8A12141C);
  static const Color textDark = Color(0x6112141C);
  static const Color textHint = Color(0x4D12141C);

  static const Color success = Color(0xFF00A854);
  static const Color successBg = Color(0xFFE3F8ED);
  static const Color warning = Color(0xFFE68A00);
  static const Color warningBg = Color(0xFFFFF1DE);
  static const Color error = Color(0xFFE0393E);
  static const Color errorBg = Color(0xFFFCE6E6);
  static const Color info = Color(0xFF0288D1);
  static const Color infoBg = Color(0xFFE3F3FB);
  static const Color discountColor = Color(0xFFE0393E);

  static const Color dividerColor = Color(0x1F12141C);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF0F1F5);

  static const Color ratingStar = Color(0xFFE6A700);
  static const Color favoriteActive = Color(0xFFE0246E);
  static const Color freeShipping = Color(0xFF00A854);
}
