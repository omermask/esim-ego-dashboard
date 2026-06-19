import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors_unified.dart';
import '../utils/responsive_size.dart';
import '../utils/navigation_utils.dart';

class OptionItem<T> {
  final T? value;
  final String label;

  const OptionItem({required this.value, required this.label});
}

class OptionSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required List<OptionItem<T>> items,
    T? selectedValue,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(rs(ctx, 28)),
            topRight: Radius.circular(rs(ctx, 28)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: rs(ctx, 12)),
            Container(
              width: rs(ctx, 32),
              height: rs(ctx, 3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                borderRadius: BorderRadius.circular(rs(ctx, 1.5)),
              ),
            ),
            SizedBox(height: rs(ctx, 16)),
            ...items.map((item) {
              final isSelected = selectedValue == item.value;
              return InkWell(
                onTap: () {
                  safePop(ctx, item.value);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rs(ctx, 24),
                    vertical: rs(ctx, 16),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryMint.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: rs(ctx, 16),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryDarkGreen
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                          ),
                        ),
                      ),
                      if (isSelected)
                        SvgPicture.asset(
                          'assets/icons/tick_circle_icon_241974.svg',
                          width: rs(ctx, 20), height: rs(ctx, 20),
                          colorFilter: const ColorFilter.mode(AppColors.primaryDarkGreen, BlendMode.srcIn),
                        ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom),
          ],
        ),
      ),
    );
  }
}
