import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors_unified.dart';

enum ToastType { success, error, info }

class CustomToaster {
  static void showError(BuildContext context, {String? title, String? message}) {
    _show(context, title: title, message: message, type: ToastType.error);
  }

  static void showSuccess(BuildContext context, {String? title, String? message}) {
    _show(context, title: title, message: message, type: ToastType.success);
  }

  static void showInfo(BuildContext context, {String? title, String? message}) {
    _show(context, title: title, message: message, type: ToastType.info);
  }

  static void _show(
    BuildContext context, {
    String? title,
    String? message,
    required ToastType type,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final textAlign = isRtl ? TextAlign.right : TextAlign.left;

    final (Color bg, Color accent, String iconPath) = switch (type) {
      ToastType.error => (
        isDark ? const Color(0xFF3D1F1F) : const Color(0xFFFDEDED),
        isDark ? const Color(0xFFEF9A9A) : AppColors.error,
        'assets/icons/warning_icon_123234.svg',
      ),
      ToastType.success => (
        isDark ? const Color(0xFF1B3D2B) : const Color(0xFFE8F5E9),
        isDark ? const Color(0xFF81C784) : BrandColors.primaryDarkGreen,
        'assets/icons/tick_circle_icon_241974.svg',
      ),
      ToastType.info => (
        isDark ? const Color(0xFF1A2B3D) : const Color(0xFFE3F2FD),
        isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0),
        'assets/icons/info_square_icon_184028.svg',
      ),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 24,
        ),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dismissDirection: DismissDirection.horizontal,
        content: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accent.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(iconPath, width: 20, height: 20,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(width: isRtl ? 0 : 12, height: isRtl ? 12 : 0),
              SizedBox(width: isRtl ? 12 : 0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: message != null && message.isNotEmpty ? 4 : 0),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          textAlign: textAlign,
                        ),
                      ),
                    if (message != null && message.isNotEmpty)
                      Text(
                        message,
                        style: TextStyle(
                          color: isDark
                              ? accent.withValues(alpha: 0.9)
                              : accent.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: textAlign,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  try { ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar(); } catch (_) {}
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset('assets/icons/close.svg',
                      width: 16, height: 16,
                      colorFilter: ColorFilter.mode(accent.withValues(alpha: 0.7), BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void handleToaster(BuildContext context, String message, String type) {
  if (type == 'copied') {
    CustomToaster.showSuccess(context, message: message);
  }
}

extension ToastExtension on BuildContext {
  void showError(String message) => CustomToaster.showError(this, message: message);
  void showSuccess(String message) => CustomToaster.showSuccess(this, message: message);
  void showInfo(String message) => CustomToaster.showInfo(this, message: message);
}
