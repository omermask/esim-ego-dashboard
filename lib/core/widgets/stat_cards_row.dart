import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class StatCardItem {
  final String label;
  final String value;
  final Color color;

  const StatCardItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class StatCardsRow extends StatelessWidget {
  final List<StatCardItem> items;

  const StatCardsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: items.map((item) => _StatCard(
        item: item,
        isDark: isDark,
      )).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatCardItem item;
  final bool isDark;

  const _StatCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(rs(context, 12)),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary,
          borderRadius: BorderRadius.circular(rs(context, 12)),
        ),
        child: Column(
          children: [
            Text(
              item.value,
              style: TextStyle(
                color: item.color,
                fontSize: rs(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: rs(context, 4)),
            Text(
              item.label,
              style: TextStyle(
                color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                fontSize: rs(context, 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
