import 'package:flutter/material.dart';
import '../utils/bottom_sheet_style.dart';
import '../utils/responsive_size.dart';

class CustomBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    List<double>? snapPoints,
    Color? bgColor,
    Color? indicatorColor,
    Widget? header,
    Widget? footer,
    bool scroll = true,
    BoxDecoration? style,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomSheetStyle = BottomSheetStyle(
      context: context,
      isDark: isDark,
      indicatorColor: indicatorColor,
      bgColor: bgColor,
    );

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: snapPoints != null && snapPoints.isNotEmpty
            ? snapPoints[0].clamp(0.1, 1.0)
            : 0.5,
        minChildSize: snapPoints != null && snapPoints.length > 1
            ? snapPoints.last.clamp(0.1, 1.0)
            : 0.25,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: style ?? bottomSheetStyle.backgroundStyle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(context, bottomSheetStyle),
              ?header,
              if (scroll)
                Flexible(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Container(
                      padding: header == null
                          ? bottomSheetStyle.contentContainer
                          : EdgeInsets.zero,
                      child: child,
                    ),
                  ),
                )
              else
                Container(
                  padding: header == null
                      ? bottomSheetStyle.contentContainer
                      : EdgeInsets.zero,
                  child: child,
                ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHandle(
      BuildContext context, BottomSheetStyle style) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
        child: Center(
          child: Container(
            width: style.indicatorWidth,
            height: style.indicatorHeight,
            decoration: style.bottomSheetIndicator,
          ),
        ),
      ),
    );
  }
}

