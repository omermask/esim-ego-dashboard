import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Colors.black.withValues(alpha: 0.15),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(rs(context, 20)),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary,
            borderRadius: BorderRadius.circular(rs(context, 12)),
          ),
          child: SizedBox(
            width: rs(context, 32),
            height: rs(context, 32),
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cornflowerBlue),
            ),
          ),
        ),
      ),
    );
  }
}
