import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class SubCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SubCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary,
        borderRadius: BorderRadius.circular(rs(context, 12)),
      ),
      child: child,
    );
  }
}
