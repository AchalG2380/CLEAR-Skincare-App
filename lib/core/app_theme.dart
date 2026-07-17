import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';
import 'theme_controller.dart';

/// Drop-in replacement for AppColor with the exact same field names.
/// Converting a screen to support Dark Mode means:
///   1. AppColor.xxx  →  AppTheme.xxx
///   2. Remove `const` from anything holding a color
///   3. Wrap the smallest surrounding widget in Obx(() => ...)
///
/// Each getter reads ThemeController's isDarkMode.value, so when read
/// inside an Obx builder, that widget correctly rebuilds on toggle.
class AppTheme {
  AppTheme._();

  static bool get _isDark => Get.find<ThemeController>().isDarkMode.value;

  static Color get primary =>
      _isDark ? AppColor.primary : AppColorLight.primary;
  static Color get secondary =>
      _isDark ? AppColor.secondary : AppColorLight.secondary;
  static Color get backgroundColor =>
      _isDark ? AppColor.backgroundColor : AppColorLight.backgroundColor;
  static Color get surface =>
      _isDark ? AppColor.surface : AppColorLight.surface;
  static Color get buttonColor =>
      _isDark ? AppColor.buttonColor : AppColorLight.buttonColor;

  static Color get primaryText =>
      _isDark ? AppColor.primaryText : AppColorLight.primaryText;
  static Color get secondaryText =>
      _isDark ? AppColor.secondaryText : AppColorLight.secondaryText;
  static Color get titleColor =>
      _isDark ? AppColor.titleColor : AppColorLight.titleColor;
  static Color get textMuted =>
      _isDark ? AppColor.textMuted : AppColorLight.textMuted;
  static Color get textDim =>
      _isDark ? AppColor.textDim : AppColorLight.textDim;
  static Color get textDark =>
      _isDark ? AppColor.textDark : AppColorLight.textDark;
  static Color get textHint =>
      _isDark ? AppColor.textHint : AppColorLight.textHint;

  static Color get success =>
      _isDark ? AppColor.success : AppColorLight.success;
  static Color get successBg =>
      _isDark ? AppColor.successBg : AppColorLight.successBg;
  static Color get warning =>
      _isDark ? AppColor.warning : AppColorLight.warning;
  static Color get warningBg =>
      _isDark ? AppColor.warningBg : AppColorLight.warningBg;
  static Color get error => _isDark ? AppColor.error : AppColorLight.error;
  static Color get errorBg =>
      _isDark ? AppColor.errorBg : AppColorLight.errorBg;
  static Color get info => _isDark ? AppColor.info : AppColorLight.info;
  static Color get infoBg => _isDark ? AppColor.infoBg : AppColorLight.infoBg;
  static Color get discountColor =>
      _isDark ? AppColor.discountColor : AppColorLight.discountColor;

  static Color get dividerColor =>
      _isDark ? AppColor.dividerColor : AppColorLight.dividerColor;
  static Color get cardBackground =>
      _isDark ? AppColor.cardBackground : AppColorLight.cardBackground;
  static Color get inputFill =>
      _isDark ? AppColor.inputFill : AppColorLight.inputFill;

  static Color get ratingStar =>
      _isDark ? AppColor.ratingStar : AppColorLight.ratingStar;
  static Color get favoriteActive =>
      _isDark ? AppColor.favoriteActive : AppColorLight.favoriteActive;
  static Color get freeShipping =>
      _isDark ? AppColor.freeShipping : AppColorLight.freeShipping;

  static Brightness get statusBarBrightness =>
      _isDark ? Brightness.light : Brightness.dark;
}
