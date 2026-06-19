import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class OptimizedWidgetBuilder {
  static Widget optimizedListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    bool addRepaintBoundary = true,
    ScrollPhysics? physics,
  }) {
    Widget listView = ListView.builder(
      itemCount: itemCount,
      itemBuilder: addRepaintBoundary
          ? (context, index) => RepaintBoundary(child: itemBuilder(context, index))
          : itemBuilder,
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
    );

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: listView,
    );
  }

  static Widget optimizedGridView({
    required SliverGridDelegate gridDelegate,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    bool addRepaintBoundary = true,
  }) {
    Widget gridView = GridView.builder(
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: addRepaintBoundary
          ? (context, index) => RepaintBoundary(child: itemBuilder(context, index))
          : itemBuilder,
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
    );

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: gridView,
    );
  }

  static Function(Function()) createDebouncer([int milliseconds = 300]) {
    Timer? debouncer;
    return (Function() action) {
      debouncer?.cancel();
      debouncer = Timer(Duration(milliseconds: milliseconds), action);
    };
  }

  static Function(Function()) createThrottler([int milliseconds = 300]) {
    bool shouldCall = true;

    return (Function() action) {
      if (shouldCall) {
        action();
        shouldCall = false;
        Timer(Duration(milliseconds: milliseconds), () {
          shouldCall = true;
        });
      }
    };
  }
}

mixin OptimizedLoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> runWithLoading(Future<void> Function() operation) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await operation();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget buildConditionalLoader(Widget child, {bool? loadingCondition}) {
    final showLoader = loadingCondition ?? _isLoading;
    if (!showLoader) return child;

    return Stack(
      children: [
        child,
        Container(
          color: Colors.black.withValues(alpha: 0.1),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      ],
    );
  }
}

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget Function(Object error)? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width != null ? (width! ~/ 2).toInt() : null,
      cacheHeight: height != null ? (height! ~/ 2).toInt() : null,
      filterQuality: FilterQuality.low,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: SvgPicture.asset('assets/icons/image_icon_184009.svg',
                width: 24, height: 24,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        if (errorWidget != null) {
          return errorWidget!(error);
        }
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: SvgPicture.asset('assets/icons/image_icon_184009.svg',
                width: 24, height: 24,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
            );
      },
    );
  }
}
