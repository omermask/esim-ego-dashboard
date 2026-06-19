import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';

class FloatingNavigationButton extends StatefulWidget {
  final VoidCallback onTap;
  final String? heroTag;

  const FloatingNavigationButton({
    super.key,
    required this.onTap,
    this.heroTag,
  });

  @override
  State<FloatingNavigationButton> createState() =>
      _FloatingNavigationButtonState();
}

class _FloatingNavigationButtonState extends State<FloatingNavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Offset _position = const Offset(300, 600);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
    _loadPosition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final x = prefs.getDouble('floating_nav_button_x');
      final y = prefs.getDouble('floating_nav_button_y');
      if (x != null && y != null) {
        setState(() {
          _position = Offset(x, y);
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _savePosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('floating_nav_button_x', _position.dx);
      await prefs.setDouble('floating_nav_button_y', _position.dy);
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _position.dx.clamp(0.0, screenSize.width - rs(context, 56)),
      top: _position.dy.clamp(0.0, screenSize.height - rs(context, 56)),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _isDragging = true;
              _position = Offset(
                (_position.dx + details.delta.dx)
                    .clamp(0.0, screenSize.width - rs(context, 56)),
                (_position.dy + details.delta.dy)
                    .clamp(0.0, screenSize.height - rs(context, 56)),
              );
            });
          },
          onPanEnd: (details) {
            setState(() {
              _isDragging = false;
            });
            _savePosition();
          },
          onTap: () {
            if (!_isDragging) {
              widget.onTap();
            }
          },
          child: Container(
            width: rs(context, 56),
            height: rs(context, 56),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.bgPrimary : AppColors.bgPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: rs(context, 8),
                  offset: Offset(0, rs(context, 4)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(rs(context, 28)),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/sidebar_left_icon_242157.svg',
                    width: rs(context, 24),
                    height: rs(context, 24),
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

