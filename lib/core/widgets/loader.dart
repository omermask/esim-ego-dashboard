import 'package:flutter/material.dart';

class Loader extends StatefulWidget {
  final String source;
  final Size? size;
  final Color color;
  final VoidCallback? onAnimationFinish;
  final bool autoplay;
  final bool loop;
  final double speed;
  final String keypath;

  const Loader({
    super.key,
    required this.source,
    this.size,
    this.color = const Color(0xFF000000),
    this.onAnimationFinish,
    this.autoplay = true,
    this.loop = true,
    this.speed = 1.5,
    this.keypath = 'loader',
  });

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autoplay && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (widget.loop) {
            _animationController.repeat();
          } else {
            _animationController.forward().then((_) {
              if (mounted && widget.onAnimationFinish != null) {
                widget.onAnimationFinish!();
              }
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: SizedBox(
          width: widget.size?.width ?? 48,
          height: widget.size?.height ?? 48,
          child: CircularProgressIndicator(
            color: widget.color,
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
}
