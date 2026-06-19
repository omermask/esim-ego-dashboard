import 'package:flutter/material.dart';

class CustomRectangleStyle {
  final double height;
  final double width;
  final double radius;
  final Color bgColor;

  CustomRectangleStyle({
    required this.height,
    required this.width,
    required this.radius,
    required this.bgColor,
  });

  BoxDecoration get container {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
