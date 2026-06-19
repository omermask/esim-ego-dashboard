import 'package:flutter/widgets.dart';

void safePop(BuildContext context, [dynamic result]) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop(result);
  }
}
