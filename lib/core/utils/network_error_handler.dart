import 'package:flutter/material.dart';
import 'toaster.dart';
import 'translation.dart';

class NetworkErrorHandler {
  static void handleNetworkError(BuildContext context, String errorMessage) {
    if (errorMessage.contains('MAINTENANCE_MODE_ACTIVE')) return;

    if (isNetworkError(errorMessage)) {
      CustomToaster.showError(
        context,
        title: trans(context, 'Network Error'),
        message: trans(context, 'Please check your network settings and try again.'),
      );
      return;
    }

    if (isAuthError(errorMessage)) {
      CustomToaster.showError(
        context,
        title: trans(context, 'Session Expired'),
        message: trans(context, 'Your session has expired. Please login again.'),
      );
      return;
    }

    CustomToaster.showError(
      context,
      title: trans(context, 'Error'),
      message: trans(context, errorMessage),
    );
  }

  static bool isNetworkError(String msg) {
    final networkErrors = [
      'Cannot connect to server', 'Network error', 'Failed host lookup',
      'Connection refused', 'Connection timeout', 'SocketException'
    ];
    return networkErrors.any((err) => msg.contains(err));
  }

  static bool isAuthError(String msg) {
    return msg.contains('Unauthorized') || msg.contains('Token expired') || msg.contains('401') || msg.contains('403');
  }
}
