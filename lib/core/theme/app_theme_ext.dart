import 'package:flutter/material.dart';
import 'theme_extensions.dart';

extension DialogColorsX on BuildContext {
  StroappDialogColors get dialogColors => Theme.of(this).extension<StroappDialogColors>()!;
}

extension ScreenColorsX on BuildContext {
  AppScreenColors get screenColors => Theme.of(this).extension<AppScreenColors>()!;
}
