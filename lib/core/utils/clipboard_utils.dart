import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

final List<Timer> _clipboardTimers = [];

void secureCopy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));

  for (final timer in _clipboardTimers) {
    timer.cancel();
  }
  _clipboardTimers.clear();

  final timer = Timer(const Duration(seconds: 30), () {
    Clipboard.setData(const ClipboardData(text: ''));
  });
  _clipboardTimers.add(timer);
}

void clearClipboardTimers() {
  for (final timer in _clipboardTimers) {
    timer.cancel();
  }
  _clipboardTimers.clear();
}
