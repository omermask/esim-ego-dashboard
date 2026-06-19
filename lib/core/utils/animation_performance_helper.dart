import 'package:flutter/material.dart';

class AnimationPerformanceHelper {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOut;

  static Duration get fastDuration => const Duration(milliseconds: 150);
  static Duration get mediumDuration => const Duration(milliseconds: 300);
  static Duration get slowDuration => const Duration(milliseconds: 500);

  static Widget animatedWidget({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    bool visible = true,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  static Widget animatedSwitcher({
    required Widget currentChild,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: currentChild,
    );
  }

  static Widget smoothContainer({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    BoxDecoration? decoration,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      margin: margin,
      padding: padding,
      color: decoration == null ? color : null,
      decoration: decoration ??
          BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            boxShadow: boxShadow,
          ),
      width: width,
      height: height,
      child: child,
    );
  }

  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget slideTransition({
    required Animation<Offset> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  static Widget sizeTransition({
    required Animation<double> animation,
    required Widget child,
    Axis axis = Axis.vertical,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      axis: axis,
      child: child,
    );
  }
}

class AnimatedBuilderHelper {
  static Widget buildAnimatedBuilder({
    required Animation<double> animation,
    required Widget Function(BuildContext, Widget?) builder,
    Widget? child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class TweenAnimationHelper {
  static Widget buildTweenAnimationBuilder<T>({
    required Tween<T> tween,
    required Duration duration,
    required Widget Function(BuildContext, T, Widget?) builder,
    Curve curve = Curves.easeInOut,
    Widget? child,
  }) {
    return TweenAnimationBuilder<T>(
      tween: tween,
      duration: duration,
      curve: curve,
      builder: builder,
      child: child,
    );
  }
}

class PageTransitionHelper {
  static Route<T> _createPageRoute<T>(Widget page, Duration duration, Curve curve) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(parent: animation, curve: curve),
          ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  static Future<T?> pushPage<T>(BuildContext context, Widget page,
      {Duration duration = AnimationPerformanceHelper.defaultDuration,
      Curve curve = AnimationPerformanceHelper.defaultCurve}) {
    return Navigator.of(context).push<T>(
      _createPageRoute<T>(page, duration, curve),
    );
  }

  static Future<T?> pushReplacementPage<T>(BuildContext context, Widget page,
      {Duration duration = AnimationPerformanceHelper.defaultDuration,
      Curve curve = AnimationPerformanceHelper.defaultCurve}) {
    return Navigator.of(context).pushReplacement<T, dynamic>(
      _createPageRoute<T>(page, duration, curve),
    );
  }

  static Future<T?> pushAndRemoveAll<T>(BuildContext context, Widget page,
      {Duration duration = AnimationPerformanceHelper.defaultDuration,
      Curve curve = AnimationPerformanceHelper.defaultCurve}) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _createPageRoute<T>(page, duration, curve),
      (route) => false,
    );
  }
}
