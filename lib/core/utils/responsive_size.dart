import 'package:flutter/widgets.dart';

double rs(BuildContext context, double size) {
  try {
    if (!context.mounted) {
      return size;
    }
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return size;
    }
    return rsWithHeight(mediaQuery.size.height, size);
  } catch (e) {
    return size;
  }
}

double rsWithHeight(double height, double size) {
  if (height > 800) {
    return (size / 860) * height;
  } else if (height > 750) {
    return (size / 810) * height;
  } else if (height > 700) {
    return (size / 760) * height;
  } else if (height > 650) {
    return (size / 710) * height;
  } else if (height > 600) {
    return (size / 660) * height;
  } else if (height > 550) {
    return (size / 610) * height;
  } else if (height > 500) {
    return (size / 560) * height;
  } else {
    return (size / 510) * height;
  }
}
