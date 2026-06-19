import 'package:flutter/material.dart';
import '../utils/custom_rectangle_style.dart';

class CustomRectangle extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final Color bgColor;
  final BoxDecoration? style;

  const CustomRectangle({
    super.key,
    required this.height,
    required this.width,
    required this.radius,
    required this.bgColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final customRectangleStyle = CustomRectangleStyle(
      height: height,
      width: width,
      radius: radius,
      bgColor: bgColor,
    );

    return Container(
      decoration: style ?? customRectangleStyle.container,
      width: width,
      height: height,
    );
  }
}

