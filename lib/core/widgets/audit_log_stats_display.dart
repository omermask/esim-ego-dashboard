import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class AuditLogStatsDisplay extends StatelessWidget {
  final int totalLogs;
  final int createdCount;
  final int updatedCount;
  final int uniqueUsers;

  const AuditLogStatsDisplay({
    super.key,
    required this.totalLogs,
    required this.createdCount,
    required this.updatedCount,
    required this.uniqueUsers,
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
              'assets/icons/warning_icon_242116.svg',
            ),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: _buildStatItem(
              context,
              isDark,
              'Created',
              '$createdCount',
              'assets/icons/tick_circle_icon_241974.svg',
            ),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: _buildStatItem(
              context,
              isDark,
              'Updated',
              '$updatedCount',
              'assets/icons/setting_icon_241871.svg',
            ),
          ),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: _buildStatItem(
              context,
              isDark,
              'Users',
              '$uniqueUsers',
              'assets/icons/profile_user.svg',
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
    String svgPath,
  ) {
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

