import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

class BackgroundTaskManager {
  static final BackgroundTaskManager _instance = BackgroundTaskManager._internal();
  factory BackgroundTaskManager() => _instance;
  BackgroundTaskManager._internal();

  static Future<T> compute<T, R>(ComputeCallback<R, T> callback, R message) async {
    if (kIsWeb) {
      return callback(message);
    }

    try {
      return await Isolate.run(() => callback(message));
    } catch (e) {
      return callback(message);
    }
  }

  static void debounce(
    VoidCallback function,
    Duration delay, {
    Completer? completer,
  }) {
    completer?.complete();
    Timer(delay, function);
  }

  static void throttle(
    VoidCallback function,
    Duration interval, {
    bool leading = true,
    bool trailing = true,
  }) {
    bool isCalled = false;

    if (leading) {
      function();
    }

    Timer.periodic(interval, (timer) {
      if (isCalled) {
        function();
        isCalled = false;
      } else if (trailing) {
        function();
        timer.cancel();
      }
    });

    isCalled = true;
  }

  static Future<T> withTimeout<T>(
    Future<T> future,
    Duration timeout, {
    T Function()? onTimeout,
  }) async {
    try {
      return await future.timeout(timeout);
    } catch (e) {
      if (onTimeout != null) {
        return onTimeout();
      }
      rethrow;
    }
  }

  static Future<List<T>> batchProcess<T>(
    List<Future<T>> futures, {
    int maxConcurrent = 5,
  }) async {
    final results = <T>[];
    final pending = <Future<T>>[];

    for (final future in futures) {
      pending.add(future);

      if (pending.length >= maxConcurrent) {
        final completed = await Future.any(pending);
        results.add(completed);
        pending.remove(completed);
      }
    }

    results.addAll(await Future.wait(pending));
    return results;
  }
}
