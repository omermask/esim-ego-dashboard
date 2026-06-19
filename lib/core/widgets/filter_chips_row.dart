import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_size.dart';

class FilterChipItem {
  final String? value;
  final String label;

  const FilterChipItem({required this.value, required this.label});
}

class FilterChipsRow extends StatelessWidget {
  final List<FilterChipItem> items;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;
  final double height;

  const FilterChipsRow({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: rs(context, height),
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedValue == item.value;
          return Container(
            margin: EdgeInsets.only(right: rs(context, 8)),
            child: FilterChip(
              label: Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  fontSize: rs(context, 12),
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(item.value),
              selectedColor: AppColors.cornflowerBlue,
              backgroundColor:
                  isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary,
              checkmarkColor: AppColors.white,
            ),
          );
        },
      ),
    );
  }
}
