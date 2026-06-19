import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// Maintenance Mode Dialog Widget
class MaintenanceModeDialog extends StatelessWidget {
  final String message;
  final String? imageUrl;
  final String? endDatetime;

  const MaintenanceModeDialog({
    super.key,
    required this.message,
    this.imageUrl,
    this.endDatetime,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? imageUrl,
    String? endDatetime,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MaintenanceModeDialog(
          message: message,
          imageUrl: imageUrl,
          endDatetime: endDatetime,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: isDark ? AppColorsDark.bgSecondary : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            SvgPicture.asset(
              'assets/icons/setting_icon_241871.svg',
              width: 48, height: 48,
              colorFilter: const ColorFilter.mode(AppColors.sunshade, BlendMode.srcIn),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Maintenance Mode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // End time if provided
            if (endDatetime != null) ...[
              Text(
                'Expected completion: $endDatetime',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColorsDark.textTertiary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // OK Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sunshade,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}