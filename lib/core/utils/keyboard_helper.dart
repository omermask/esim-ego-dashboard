import 'package:flutter/material.dart';

class KeyboardHelper {
  static const EdgeInsets scrollPadding = EdgeInsets.all(20.0);

  static EdgeInsets scrollPaddingWith(double padding) {
    return EdgeInsets.all(padding);
  }

  static Widget smoothKeyboardScrollView({
    required Widget child,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return SingleChildScrollView(
      controller: controller,
      padding: padding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }
}
