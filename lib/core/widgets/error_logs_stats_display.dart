import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class ErrorLogsStatsDisplay extends StatelessWidget {
  final int totalLogs;
  final int errorCount;
  final int warningCount;
  final int infoCount;

  const ErrorLogsStatsDisplay({
    super.key,
    required this.totalLogs,
    required this.errorCount,
    required this.warningCount,
    required this.infoCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: rs(context, 16),
        vertical: rs(context, 12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              isDark,
              'Total Logs',
              '$totalLogs',
              'assets/icons/note_icon_242077.svg',
            ),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: _buildStatItem(
              context,
              isDark,
              'Errors',
              '$errorCount',
              'assets/icons/warning_icon_242116.svg',
              color: AppColors.ceriseRed,
            ),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: _buildStatItem(
              context,
              isDark,
              'Warnings',
              '$warningCount',
              'assets/icons/warning_icon_242116.svg',
              color: AppColors.sunshade,
            ),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: _buildStatItem(
              context,
              isDark,
              'Info',
              '$infoCount',
              'assets/icons/note_icon_242077.svg',
              color: AppColors.cornflowerBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    bool isDark,
    String title,
    String value,
    String svgPath, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 10),
        vertical: rs(context, 12),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.bgQuaternary : AppColors.bgQuaternary,
        borderRadius: BorderRadius.circular(rs(context, 10)),
        border: Border.all(
          color: isDark ? AppColorsDark.borderPrimary : AppColors.borderPrimary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgPath,
            width: rs(context, 24),
            height: rs(context, 24),
            colorFilter: color != null
                ? ColorFilter.mode(color, BlendMode.srcIn)
                : null,
          ),
          SizedBox(height: rs(context, 6)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Gilroy-Bold',
              fontSize: rs(context, 16),
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: rs(context, 4)),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Gilroy-Medium',
              fontSize: rs(context, 10),
              color: isDark ? AppColorsDark.textTertiary : AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

