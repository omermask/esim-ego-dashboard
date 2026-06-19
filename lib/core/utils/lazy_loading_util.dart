import 'dart:async';
import 'package:flutter/material.dart';

class LazyLoadingUtil {
  static Widget buildLazyListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required Future<bool> Function(int page) onLoadMore,
    required ScrollController scrollController,
    Widget? separatorBuilder,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    int pageSize = 20,
    Widget? loadingIndicator,
    Widget? noMoreItemsWidget,
    Widget? errorWidget,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.extentAfter < 100 && items.length % pageSize == 0) {
            onLoadMore((items.length ~/ pageSize) + 1);
          }
        }
        return false;
      },
      child: ListView.separated(
        controller: scrollController,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: items.length + 1,
        separatorBuilder: (context, index) {
          if (separatorBuilder != null && index < items.length) {
            return separatorBuilder;
          }
          return const SizedBox.shrink();
        },
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildLoadingIndicator(loadingIndicator);
          }
          return itemBuilder(context, items[index]);
        },
      ),
    );
  }

  static Widget _buildLoadingIndicator(Widget? customIndicator) {
    if (customIndicator != null) {
      return customIndicator;
    }

    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static ScrollController createDebouncedScrollController({
    VoidCallback? onScrollStart,
    VoidCallback? onScrollEnd,
    Duration debounceDuration = const Duration(milliseconds: 100),
  }) {
    Timer? scrollTimer;

    return ScrollController()
      ..addListener(() {
        if (scrollTimer?.isActive ?? false) {
          scrollTimer!.cancel();
        }

        onScrollStart?.call();

        scrollTimer = Timer(debounceDuration, () {
          onScrollEnd?.call();
        });
      });
  }

  static Widget buildLazyGridView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required Future<bool> Function(int page) onLoadMore,
    required ScrollController scrollController,
    required int crossAxisCount,
    double crossAxisSpacing = 0,
    double mainAxisSpacing = 0,
    double childAspectRatio = 1.0,
    EdgeInsets? padding,
    int pageSize = 20,
    Widget? loadingIndicator,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.extentAfter < 100 && items.length % pageSize == 0) {
            onLoadMore((items.length ~/ pageSize) + 1);
          }
        }
        return false;
      },
      child: GridView.builder(
        controller: scrollController,
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildLoadingIndicator(loadingIndicator);
          }
          return itemBuilder(context, items[index]);
        },
      ),
    );
  }

  static Widget buildEfficientListItem({
    required Widget child,
    required bool isVisible,
    Key? key,
  }) {
    return Visibility(
      key: key,
      visible: isVisible,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: child,
    );
  }

  static ScrollPhysics createSmoothScrollPhysics() {
    return const ClampingScrollPhysics().applyTo(
      const BouncingScrollPhysics(),
    );
  }
}
