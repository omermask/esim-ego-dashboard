import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors_unified.dart';
import 'theme_extensions.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primaryDarkGreen,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDarkGreen, secondary: AppColors.accentCopper,
        surface: AppColors.surfaceLight, error: AppColors.error,
        onPrimary: AppColors.buttonTextLight, onSurface: AppColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(color: AppColors.textPrimaryLight, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLightGreen, foregroundColor: AppColors.buttonTextLight,
          disabledBackgroundColor: AppColors.disabledButtonLight, disabledForegroundColor: AppColors.disabledTextLight,
          elevation: 0, minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: AppColors.surfaceHighlightLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
        labelStyle: TextStyle(color: AppColors.textPrimaryLight, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryLightGreen, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 0.5, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primaryMint : const Color(0xFFD1D1D6)),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      extensions: const [StroappDialogColors.light, AppScreenColors.light],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryMint,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryMint, secondary: AppColors.accentCopper,
        surface: AppColors.surfaceDark, error: AppColors.error,
        onPrimary: AppColors.buttonTextDark, onSurface: AppColors.textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(color: AppColors.textPrimaryDark, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMint, foregroundColor: AppColors.buttonTextDark,
          disabledBackgroundColor: AppColors.disabledButtonDark, disabledForegroundColor: AppColors.disabledTextDark,
          elevation: 0, minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFF383838),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
        labelStyle: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderDark)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentCopper, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderDark, width: 0.5)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 0.5, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primaryMint : AppColors.textSecondaryDark),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primaryMint : AppColors.surfaceHighlightDark),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      extensions: const [StroappDialogColors.dark, AppScreenColors.dark],
    );
  }
}
