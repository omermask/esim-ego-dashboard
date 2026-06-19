import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyStatusBar extends StatelessWidget {
  final Color backgroundColor;
  final String barStyle;

  const MyStatusBar({
    super.key,
    required this.backgroundColor,
    this.barStyle = 'light-content',
  });

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding;
    final height = insets.top;

    Brightness statusBarIconBrightness;
    if (barStyle == 'light-content') {
      statusBarIconBrightness = Brightness.light;
    } else {
      statusBarIconBrightness = Brightness.dark;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: barStyle == 'light-content'
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Container(
        color: backgroundColor,
        height: height,
      ),
    );
  }
}
