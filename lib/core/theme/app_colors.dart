import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color cornflowerBlue = Color(0xFF6495ED);
  static const Color eucalyptus = Color(0xFF44D7B6);
  static const Color ceriseRed = Color(0xFFDE3163);
  static const Color sunshade = Color(0xFFFF8C00);
  static const Color bastille = Color(0xFF2C2C3A);

  // Light theme
  static const Color bgPrimary = Color(0xFFF2F6F4);
  static const Color bgSecondary = Color(0xFFE2ECE6);
  static const Color bgQuaternary = Color(0xFFD0DDD6);
  static const Color borderPrimary = Color(0xFFB6C6BC);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF4D5A53);
  static const Color textTertiary = Color(0xFF8A9D93);
  static const Color textOctonary = Color(0xFFB6C6BC);
  static const Color textOctonaryVariant = Color(0xFF8A9D93);
  static const Color copyPrimary = Color(0xFF4D5A53);
  static const Color btnSecondary = Color(0xFFD0DDD6);
  static const Color ifSecondary = Color(0xFF4D5A53);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gunPowder = Color(0xFF2C2C3A);
  static const Color textTertiaryVariant = Color(0xFF8A9D93);
  static const Color tabIconUnfocused = Color(0xFF71717A);
  static const Color snuff = Color(0xFFD0DDD6);
  static const Color mischka = Color(0xFFB6C6BC);
  static const Color stormGray = Color(0xFF3F3F46);

  // keep unified colors for backward compat
  static const Color primaryMint = Color(0xFFA5CDBF);
  static const Color primaryDarkGreen = Color(0xFF2A4543);
  static const Color primaryLightGreen = Color(0xFF185A46);
  static const Color accentCopper = Color(0xFFED6A46);
  static const Color success = Color(0xFFABCDBA);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFFE9901);

  static const Color backgroundLight = Color(0xFFF2F6F4);
  static const Color surfaceLight = Color(0xFFE2ECE6);
  static const Color surfaceHighlightLight = Color(0xFFD0DDD6);
  static const Color textPrimaryLight = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF4D5A53);
  static const Color borderLight = Color(0xFFB6C6BC);
  static const Color infoValueLight = Color(0xFF1A1A1C);
  static const Color disabledButtonLight = Color(0xFFBDBDBD);
  static const Color disabledTextLight = Color(0xFF9E9E9E);
  static const Color buttonTextLight = Color(0xFFEAF5F0);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF2A2A2C);
  static const Color surfaceHighlightDark = Color(0xFF333333);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);
  static const Color borderDark = Color(0xFF3F3F46);
  static const Color iconTintDark = Color(0xFFFFFFFF);
  static const Color disabledButtonDark = Color(0xFF555555);
  static const Color disabledTextDark = Color(0xFF888888);
  static const Color buttonTextDark = Color(0xFF121212);

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D3B2E), Color(0xFF2D1B69)],
  );
}

class AppColorsDark {
  static const Color bgPrimary = Color(0xFF121212);
  static const Color bgSecondary = Color(0xFF2A2A2C);
  static const Color bgQuaternary = Color(0xFF333333);
  static const Color borderPrimary = Color(0xFF3F3F46);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textOctonary = Color(0xFF3F3F46);
  static const Color textOctonaryVariant = Color(0xFF71717A);
  static const Color textTertiaryVariant = Color(0xFF8A9D93);
  static const Color copyPrimary = Color(0xFFA1A1AA);
  static const Color btnSecondary = Color(0xFF333333);
  static const Color ifSecondary = Color(0xFFA1A1AA);
  static const Color tabIconUnfocused = Color(0xFF71717A);
}
