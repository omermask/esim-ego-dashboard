import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTransitionLoader {
  static final Map<BuildContext, DateTime> _showTimes = {};

  static void show(BuildContext context) {
    _showTimes[context] = DateTime.now();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final smoothAnim = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.05, 0.7, 0.1, 1.0),
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0 * smoothAnim.value,
            sigmaY: 10.0 * smoothAnim.value,
          ),
          child: Center(
            child: FadeTransition(
              opacity: smoothAnim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Cubic(0.34, 1.56, 0.64, 1.0),
                  ),
                ),
                child: RepaintBoundary(
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 45,
                        height: 45,
                        errorBuilder: (_, _, _) => SvgPicture.asset(
                          'assets/icons/loading_icon_149916.svg',
                          width: 45,
                          height: 45,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> hide(BuildContext context) async {
    final shownAt = _showTimes.remove(context);
    if (shownAt != null) {
      final elapsed = DateTime.now().difference(shownAt);
      const minDuration = Duration(milliseconds: 800);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }
}
