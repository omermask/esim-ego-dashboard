import 'package:flutter/material.dart';
import 'app_colors_unified.dart';

@immutable
class StroappDialogColors extends ThemeExtension<StroappDialogColors> {
  final Color bg;
  final Color accent;
  final Color iconBox;
  final Color inputField;
  final Color primaryBtn;
  final Color selectionBtn;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const StroappDialogColors({
    required this.bg, required this.accent, required this.iconBox,
    required this.inputField, required this.primaryBtn, required this.selectionBtn,
    required this.textPrimary, required this.textSecondary, required this.borderColor,
  });

  static const StroappDialogColors dark = StroappDialogColors(
    bg: Color(0xFF2A2A2C), accent: Color(0xFFFFB28B), iconBox: Color(0xFF333333),
    inputField: Color(0xFF2A2A2C), primaryBtn: Color(0xFFA5CDBF), selectionBtn: Color(0xFFA5CDBF),
    textPrimary: Color(0xFFFFFFFF), textSecondary: Color(0xFFA1A1AA), borderColor: Color(0xFF3F3F46),
  );

  static const StroappDialogColors light = StroappDialogColors(
    bg: Color(0xFFE2ECE6), accent: Color(0xFFED6A46), iconBox: Color(0xFFD0DDD6),
    inputField: Color(0xFFD0DDD6), primaryBtn: Color(0xFF185A46), selectionBtn: Color(0xFF185A46),
    textPrimary: Color(0xFF111111), textSecondary: Color(0xFF4D5A53), borderColor: Color(0xFFB6C6BC),
  );

  @override
  StroappDialogColors copyWith({Color? bg, Color? accent, Color? iconBox, Color? inputField, Color? primaryBtn, Color? selectionBtn, Color? textPrimary, Color? textSecondary, Color? borderColor}) {
    return StroappDialogColors(
      bg: bg ?? this.bg, accent: accent ?? this.accent, iconBox: iconBox ?? this.iconBox,
      inputField: inputField ?? this.inputField, primaryBtn: primaryBtn ?? this.primaryBtn,
      selectionBtn: selectionBtn ?? this.selectionBtn, textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary, borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  StroappDialogColors lerp(covariant ThemeExtension<StroappDialogColors>? other, double t) {
    if (other is! StroappDialogColors) return this;
    return StroappDialogColors(
      bg: Color.lerp(bg, other.bg, t) ?? bg, accent: Color.lerp(accent, other.accent, t) ?? accent,
      iconBox: Color.lerp(iconBox, other.iconBox, t) ?? iconBox,
      inputField: Color.lerp(inputField, other.inputField, t) ?? inputField,
      primaryBtn: Color.lerp(primaryBtn, other.primaryBtn, t) ?? primaryBtn,
      selectionBtn: Color.lerp(selectionBtn, other.selectionBtn, t) ?? selectionBtn,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
    );
  }
}

@immutable
class AppScreenColors extends ThemeExtension<AppScreenColors> {
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

  const AppScreenColors({
    required this.bg, required this.surface, required this.surfaceHighlight,
    required this.textPrimary, required this.textSecondary, required this.buttonColor,
    required this.buttonForeground, required this.border, required this.iconTint, required this.infoValue,
  });

  static const AppScreenColors light = AppScreenColors(
    bg: LightModeColors.background, surface: LightModeColors.surface,
    surfaceHighlight: LightModeColors.surfaceHighlight,
    textPrimary: LightModeColors.textPrimary, textSecondary: LightModeColors.textSecondary,
    buttonColor: BrandColors.primaryLightGreen, buttonForeground: LightModeColors.buttonText,
    border: LightModeColors.border, iconTint: LightModeColors.textSecondary,
    infoValue: LightModeColors.infoValue,
  );

  static const AppScreenColors dark = AppScreenColors(
    bg: DarkModeColors.background, surface: DarkModeColors.surface,
    surfaceHighlight: DarkModeColors.surfaceHighlight,
    textPrimary: DarkModeColors.textPrimary, textSecondary: DarkModeColors.textSecondary,
    buttonColor: BrandColors.primaryMint, buttonForeground: DarkModeColors.textInverse,
    border: DarkModeColors.border, iconTint: DarkModeColors.iconTint,
    infoValue: DarkModeColors.textPrimary,
  );

  @override
  AppScreenColors copyWith({Color? bg, Color? surface, Color? surfaceHighlight, Color? textPrimary, Color? textSecondary, Color? buttonColor, Color? buttonForeground, Color? border, Color? iconTint, Color? infoValue}) {
    return AppScreenColors(
      bg: bg ?? this.bg, surface: surface ?? this.surface,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      textPrimary: textPrimary ?? this.textPrimary, textSecondary: textSecondary ?? this.textSecondary,
      buttonColor: buttonColor ?? this.buttonColor, buttonForeground: buttonForeground ?? this.buttonForeground,
      border: border ?? this.border, iconTint: iconTint ?? this.iconTint, infoValue: infoValue ?? this.infoValue,
    );
  }

  @override
  AppScreenColors lerp(covariant ThemeExtension<AppScreenColors>? other, double t) {
    if (other is! AppScreenColors) return this;
    return AppScreenColors(
      bg: Color.lerp(bg, other.bg, t) ?? bg, surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceHighlight: Color.lerp(surfaceHighlight, other.surfaceHighlight, t) ?? surfaceHighlight,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t) ?? buttonColor,
      buttonForeground: Color.lerp(buttonForeground, other.buttonForeground, t) ?? buttonForeground,
      border: Color.lerp(border, other.border, t) ?? border,
      iconTint: Color.lerp(iconTint, other.iconTint, t) ?? iconTint,
      infoValue: Color.lerp(infoValue, other.infoValue, t) ?? infoValue,
    );
  }
}
