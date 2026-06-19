import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive_size.dart';
import '../theme/app_theme_ext.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? iconPath;
  final VoidCallback? onRetry;

  const EmptyState({
    super.key,
    required this.message,
    this.iconPath,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rs(context, 40)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath ?? 'assets/icons/empty-box.svg',
              width: rs(context, 60),
              colorFilter: ColorFilter.mode(dc.textSecondary.withValues(alpha: 0.5), BlendMode.srcIn),
            ),
            SizedBox(height: rs(context, 16)),
            Text(message,
              style: TextStyle(fontSize: rs(context, 15), color: dc.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: rs(context, 16)),
              InkWell(
                onTap: onRetry,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 24), vertical: rs(context, 10)),
                  decoration: BoxDecoration(
                    color: dc.accent,
                    borderRadius: BorderRadius.circular(rs(context, 12)),
                  ),
                  child: Text('Try Again',
                    style: TextStyle(fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
