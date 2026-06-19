import 'package:flutter/material.dart';
import 'dart:math' as math;

class RippleButton extends StatefulWidget {
  final BoxDecoration? style;
  final VoidCallback? onTap;
  final Widget children;

  const RippleButton({
    super.key,
    this.style,
    this.onTap,
    required this.children,
  });

  @override
  State<RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<RippleButton>
    with TickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  late AnimationController _scaleController;
  late AnimationController _opacityController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  double _centerX = 0;
  double _centerY = 0;
  double _width = 0;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _opacityController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final localPosition = renderBox.globalToLocal(details.globalPosition);

      setState(() {
        _width = size.width;
        _height = size.height;
        _centerX = localPosition.dx;
        _centerY = localPosition.dy;
      });

      _opacityController.value = 1;
      _scaleController.value = 0;
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _opacityController.forward();
  }

  void _handleTapCancel() {
    _opacityController.forward();
  }

  void _handleLongPress() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _handleLongPress,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: Container(
        key: _containerKey,
        decoration: widget.style,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            widget.children,
            AnimatedBuilder(
              animation: Listenable.merge([_scaleAnimation, _opacityAnimation]),
              builder: (context, child) {
                final circleRadius =
                    math.sqrt(_width * _width + _height * _height);
                final translateX = _centerX - circleRadius;
                final translateY = _centerY - circleRadius;

                return Positioned(
                  left: translateX,
                  top: translateY,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: circleRadius * 2,
                        height: circleRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
