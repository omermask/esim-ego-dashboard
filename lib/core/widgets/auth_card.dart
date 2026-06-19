import 'package:flutter/material.dart';
import '../theme/app_theme_ext.dart';
import '../utils/responsive_size.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AuthCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.fromLTRB(rs(context, 16), rs(context, 24), rs(context, 16), rs(context, 16)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.dialogColors.bg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
