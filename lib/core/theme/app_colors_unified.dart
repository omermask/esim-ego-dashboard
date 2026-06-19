import 'package:flutter/material.dart';

class BrandColors {
  static const Color primaryMint = Color(0xFFA5CDBF);
  static const Color primaryDarkGreen = Color(0xFF2A4543);
  static const Color primaryLightGreen = Color(0xFF185A46);
  static const Color accentPeach = Color(0xFFFFB28B);
  static const Color accentCopper = Color(0xFFED6A46);
  static const Color success = Color(0xFFABCDBA);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFFE9901);
  static const Color infoBackground = Color(0xFF1D5A46);
  static const Color discountBadgeBg = Color(0xFFF4B8B1);
  static const Color discountBadgeText = Color(0xFFC0392B);
}

class LightModeColors {
  static const Color background = Color(0xFFF2F6F4);
  static const Color surface = Color(0xFFE2ECE6);
  static const Color surfaceHighlight = Color(0xFFD0DDD6);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF4D5A53);
  static const Color infoValue = Color(0xFF1A1A1C);
  static const Color border = Color(0xFFB6C6BC);
  static const Color buttonText = Color(0xFFEAF5F0);
  static const Color disabledButton = Color(0xFFBDBDBD);
  static const Color disabledText = Color(0xFF9E9E9E);
}

class DarkModeColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF2A2A2C);
  static const Color surfaceHighlight = Color(0xFF333333);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textInverse = Color(0xFF121212);
  static const Color iconTint = Color(0xFFFFFFFF);
  static const Color border = Color(0xFF3F3F46);
  static const Color borderFocused = Color(0xFFA5CDBF);
  static const Color disabledButton = Color(0xFF555555);
  static const Color disabledText = Color(0xFF888888);
}

class AppGradients {
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D3B2E), Color(0xFF2D1B69)],
  );
}

class AppColors {
  static const Color primaryMint = BrandColors.primaryMint;
  static const Color primaryDarkGreen = BrandColors.primaryDarkGreen;
  static const Color primaryLightGreen = BrandColors.primaryLightGreen;
  static const Color accentCopper = BrandColors.accentCopper;
  static const Color success = BrandColors.success;
  static const Color error = BrandColors.error;
  static const Color warning = BrandColors.warning;
  static const Color backgroundLight = LightModeColors.background;
  static const Color surfaceLight = LightModeColors.surface;
  static const Color surfaceHighlightLight = LightModeColors.surfaceHighlight;
  static const Color textPrimaryLight = LightModeColors.textPrimary;
  static const Color textSecondaryLight = LightModeColors.textSecondary;
  static const Color borderLight = LightModeColors.border;
  static const Color infoValueLight = LightModeColors.infoValue;
  static const Color disabledButtonLight = LightModeColors.disabledButton;
  static const Color disabledTextLight = LightModeColors.disabledText;
  static const Color buttonTextLight = LightModeColors.buttonText;
  static const Color backgroundDark = DarkModeColors.background;
  static const Color surfaceDark = DarkModeColors.surface;
  static const Color surfaceHighlightDark = DarkModeColors.surfaceHighlight;
  static const Color textPrimaryDark = DarkModeColors.textPrimary;
  static const Color textSecondaryDark = DarkModeColors.textSecondary;
  static const Color borderDark = DarkModeColors.border;
  static const Color iconTintDark = DarkModeColors.iconTint;
  static const Color disabledButtonDark = DarkModeColors.disabledButton;
  static const Color disabledTextDark = DarkModeColors.disabledText;
  static const Color buttonTextDark = DarkModeColors.textInverse;
  static const LinearGradient cardGradient = AppGradients.cardGradient;
}

class ScreenTheme {
  final Color bg;
  final Color surface;
  final Color surfaceHighlight;
  final Color textPrimary;
  final Color textSecondary;
  final Color buttonColor;
  final Color buttonForeground;
  final Color border;
  final Color iconTint;
  final Color infoValue;
  const ScreenTheme({
    required this.bg, required this.surface, required this.surfaceHighlight,
    required this.textPrimary, required this.textSecondary,
    required this.buttonColor, required this.buttonForeground,
    required this.border, required this.iconTint, required this.infoValue,
  });
}

class ScreenColors {
  static const ScreenTheme light = ScreenTheme(
    bg: LightModeColors.background, surface: LightModeColors.surface,
    surfaceHighlight: LightModeColors.surfaceHighlight,
    textPrimary: LightModeColors.textPrimary, textSecondary: LightModeColors.textSecondary,
    buttonColor: BrandColors.primaryLightGreen, buttonForeground: LightModeColors.buttonText,
    border: LightModeColors.border, iconTint: LightModeColors.textSecondary,
    infoValue: LightModeColors.infoValue,
  );
  static const ScreenTheme dark = ScreenTheme(
    bg: DarkModeColors.background, surface: DarkModeColors.surface,
    surfaceHighlight: DarkModeColors.surfaceHighlight,
    textPrimary: DarkModeColors.textPrimary, textSecondary: DarkModeColors.textSecondary,
    buttonColor: BrandColors.primaryMint, buttonForeground: DarkModeColors.textInverse,
    border: DarkModeColors.border, iconTint: DarkModeColors.iconTint,
    infoValue: DarkModeColors.textPrimary,
  );
}

class DialogThemeColors {
  final Color bg;
  final Color accent;
  final Color iconBox;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryBtn;
  final Color borderColor;
  const DialogThemeColors({
    required this.bg, required this.accent, required this.iconBox,
    required this.textPrimary, required this.textSecondary,
    required this.primaryBtn, required this.borderColor,
  });
  static const light = DialogThemeColors(
    bg: Color(0xFFE2ECE6), accent: Color(0xFFED6A46), iconBox: Color(0xFFD0DDD6),
    textPrimary: Color(0xFF111111), textSecondary: Color(0xFF4D5A53),
    primaryBtn: Color(0xFF185A46), borderColor: Color(0xFFB6C6BC),
  );
  static const dark = DialogThemeColors(
    bg: Color(0xFF2A2A2C), accent: Color(0xFFFFB28B), iconBox: Color(0xFF333333),
    textPrimary: Color(0xFFFFFFFF), textSecondary: Color(0xFFA1A1AA),
    primaryBtn: Color(0xFFA5CDBF), borderColor: Color(0xFF3F3F46),
  );
}
