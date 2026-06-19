import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';

class ButtonLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const ButtonLoader({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rs(context, size),
      height: rs(context, size),
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }
}
