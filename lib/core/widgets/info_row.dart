import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';
import '../utils/clipboard_utils.dart';
import '../utils/toaster.dart';
import '../l10n/app_localizations.dart';
import 'sub_card.dart';

class InfoRow extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final bool copy;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.copy = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                width: rs(context, 13),
                height: rs(context, 13),
              ),
              SizedBox(width: rs(context, 6)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    fontSize: rs(context, 10),
                    color: isDark
                        ? AppColorsDark.textOctonary
                        : AppColors.textOctonary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (copy)
                GestureDetector(
                  onTap: () {
                    secureCopy(context, value);
                    final loc = AppLocalizations.of(context)!;
                    handleToaster(context, loc.copiedToClipboard, 'copied');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: rs(context, 6)),
                    child: SvgPicture.asset(
                      'assets/icons/copy.svg',
                      width: rs(context, 12),
                      height: rs(context, 12),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: rs(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Gilroy-Semibold',
              fontSize: rs(context, 12),
              color: valueColor ??
                  (isDark
                      ? AppColorsDark.textSecondary
                      : AppColors.textSecondary),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
