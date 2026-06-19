import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/models/backup_data.dart';
import 'stat_cards_row.dart';

class BackupStatsDisplay extends StatelessWidget {
  final BackupStatus status;

  const BackupStatsDisplay({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return StatCardsRow(
      items: [
        StatCardItem(
          label: 'Total',
          value: '${status.totalBackups}',
          color: AppColors.cornflowerBlue,
        ),
        StatCardItem(
          label: 'Size',
          value: status.totalBackupSizeFormatted,
          color: AppColors.eucalyptus,
        ),
        StatCardItem(
          label: 'Auto Backup',
          value: status.autoBackupEnabled ? 'On' : 'Off',
          color: status.autoBackupEnabled ? AppColors.eucalyptus : AppColors.ceriseRed,
        ),
        StatCardItem(
          label: 'Last Backup',
          value: status.lastBackupAt != null
              ? '${DateTime.now().difference(status.lastBackupAt!).inDays}d'
              : 'Never',
          color: status.lastBackupAt != null ? AppColors.sunshade : AppColors.ceriseRed,
        ),
      ],
    );
  }
}

