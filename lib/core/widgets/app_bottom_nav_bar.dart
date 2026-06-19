import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// مؤشر الشاشة النشطة في البار السفلي
enum NavTab {
  more,     // index 0 → /more
  wallet,   // index 1 → /transactions
  dashboard,// index 2 → /dashboard
  store,    // index 3 → /dashboard (مؤقتاً)
  profile,  // index 4 → /profile
}

extension NavTabX on NavTab {
  String get route {
    switch (this) {
      case NavTab.more:      return '/more';
      case NavTab.wallet:    return '/transactions';
      case NavTab.dashboard: return '/dashboard';
      case NavTab.store:     return '/card';
      case NavTab.profile:   return '/profile';
    }
  }

  static NavTab fromRoute(String location) {
    if (location.startsWith('/more'))          return NavTab.more;
    if (location.startsWith('/transactions'))  return NavTab.wallet;
    if (location.startsWith('/deposit'))       return NavTab.wallet;
    if (location.startsWith('/dashboard')) return NavTab.dashboard;
    if (location.startsWith('/card'))         return NavTab.store;
    if (location.startsWith('/profile'))       return NavTab.profile;
    return NavTab.dashboard;
  }
}

class AppBottomNavBar extends StatelessWidget {
  /// الصفحة النشطة حالياً
  final NavTab activeTab;

  const AppBottomNavBar({super.key, required this.activeTab});

  /// ترتيب التابات (للحساب الاتجاه)
  static const _tabOrder = {
    NavTab.more: 0,
    NavTab.wallet: 1,
    NavTab.dashboard: 2,
    NavTab.store: 3,
    NavTab.profile: 4,
  };

  void _onTabTap(BuildContext context, NavTab tab) {
    if (tab == activeTab) return;
    HapticFeedback.selectionClick();
    final fromIdx = _tabOrder[activeTab] ?? 2;
    final toIdx   = _tabOrder[tab]      ?? 2;
    // dx > 0 → الشاشة الجديدة تأتي من اليمين (index أكبر)
    // dx < 0 → الشاشة الجديدة تأتي من اليسار (index أصغر)
    final dx = (toIdx > fromIdx) ? 1.0 : -1.0;
    context.go(tab.route, extra: {'dx': dx});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          height: 58,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(color: scaffoldBg),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.2),
                      width: 1.0,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 68,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      _NavItem(
                        svgPath: 'assets/images/more_square.svg',
                        isActive: activeTab == NavTab.more,
                        onTap: () => _onTabTap(context, NavTab.more),
                        iconSize: 42,
                      ),
                  _NavItem(
                    svgPath: 'assets/icons/refresh_square_icon_242173.svg',
                    isActive: activeTab == NavTab.wallet,
                        onTap: () => _onTabTap(context, NavTab.wallet),
                        iconSize: 42,
                      ),
                      _NavItem(
                        svgPath: 'assets/images/home_icon_.svg',
                        isActive: activeTab == NavTab.dashboard,
                        onTap: () => _onTabTap(context, NavTab.dashboard),
                        iconSize: 42,
                      ),
                      _NavItem(
                    svgPath: 'assets/icons/toggle_on_icon_242201.svg',
                    isActive: activeTab == NavTab.store,
                        onTap: () => _onTabTap(context, NavTab.store),
                        iconSize: 42,
                      ),
                  _NavItem(
                    svgPath: 'assets/icons/user_square_icon_242125.svg',
                    isActive: activeTab == NavTab.profile,
                        onTap: () => _onTabTap(context, NavTab.profile),
                        iconSize: 42,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Widget داخلي لكل أيقونة في البار
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final bool isActive;
  final double iconSize;
  final VoidCallback onTap;

  const _NavItem({
    this.icon,
    this.svgPath,
    required this.isActive,
    required this.onTap,
    this.iconSize = 28,
  }) : assert(icon != null || svgPath != null,
            'Either icon or svgPath must be provided');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = Colors.orange;
    final inactiveColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              child: AnimatedScale(
                scale: isActive ? 1.0 : 0.85,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (svgPath != null)
                      SvgPicture.asset(
                        svgPath!,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: ColorFilter.mode(
                          isActive ? activeColor : inactiveColor,
                          BlendMode.srcIn,
                        ),
                      )
                    else
                      Icon(
                        icon,
                        color: isActive ? activeColor : inactiveColor,
                        size: iconSize,
                      ),
                    AnimatedOpacity(
                      opacity: isActive ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? activeColor : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
