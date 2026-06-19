import 'dart:io';
import 'package:flutter/material.dart';
import 'failures.dart';
import '../utils/toaster.dart';
import '../utils/translation.dart';
import '../../screens/login/phone_entry_screen.dart';

// ────────────────────────────────────────────
// 1. HTTP STATUS CODE → user-friendly message
// ────────────────────────────────────────────
String getMessageForStatusCode(BuildContext context, int statusCode) {
  switch (statusCode) {
    case 200: return trans(context, 'Request completed successfully.');
    case 201: return trans(context, 'Resource created successfully.');
    case 202: return trans(context, 'Request accepted for processing.');
    case 204: return trans(context, 'Request completed (no content).');
    case 301: return trans(context, 'Resource has been moved permanently.');
    case 302: return trans(context, 'Resource has been moved temporarily.');
    case 400: return trans(context, 'Bad request. Please check your input.');
    case 401: return trans(context, 'Authentication failed. Please log in again.');
    case 402: return trans(context, 'Payment is required to proceed.');
    case 403: return trans(context, "Access denied. You don't have permission.");
    case 404: return trans(context, 'Resource not found.');
    case 405: return trans(context, 'HTTP method not allowed.');
    case 406: return trans(context, 'Request format not acceptable.');
    case 408: return trans(context, 'Request timed out. Please try again.');
    case 409: return trans(context, 'Conflict with current resource state.');
    case 410: return trans(context, 'Resource is no longer available.');
    case 412: return trans(context, 'Precondition failed.');
    case 415: return trans(context, 'Unsupported media type.');
    case 422: return trans(context, 'Validation failed. Please check your input.');
    case 423: return trans(context, 'Resource is locked.');
    case 429: return trans(context, 'Too many requests. Please try again later.');
    case 500: return trans(context, 'Internal server error. Please try again later.');
    case 502: return trans(context, 'Bad gateway. Please try again later.');
    case 503: return trans(context, 'Service temporarily unavailable. Please try again later.');
    case 504: return trans(context, 'Gateway timed out. Please try again later.');
    default:
      if (statusCode >= 200 && statusCode < 300) return trans(context, 'Request completed successfully.');
      if (statusCode >= 300 && statusCode < 400) return trans(context, 'Redirect occurred.');
      if (statusCode >= 400 && statusCode < 500) return trans(context, 'Client error occurred. Please try again.');
      if (statusCode >= 500) return trans(context, 'Server error occurred. Please try again later.');
      return trans(context, 'An unknown error occurred.');
  }
}

// ────────────────────────────────────────────
// 2. SERVER BUSINESS CODE → Failure mapper
//
// Maps the server's snake_case error codes (from ErrorCode enum)
// to typed Failure classes. Organized by domain to match the server's
// ErrorCode definition order.
// ────────────────────────────────────────────
Failure mapServerCodeToFailure({
  required String code,
  required String message,
  int? statusCode,
  String? details,
  Map<String, List<String>>? fieldErrors,
}) {
  // ─────────────────── Auth ───────────────────
  if (code == 'auth_invalid_otp') return ValidationFailure(message, code: code, details: details);
  if (code == 'auth_expired_otp') return ResourceExpiredFailure(message, code: code, details: details);
  if (code == 'auth_max_attempts') return RateLimitFailure(message, code: code, details: details);
  if (code == 'auth_blocked') return AccountLockedFailure(message, code: code, details: details);
  if (code == 'auth_invalid_token') return UnauthorizedFailure(message, code: code, details: details);
  if (code == 'auth_token_expired') return SessionExpiredFailure(message, code: code, details: details);
  if (code == 'auth_token_revoked') return UnauthorizedFailure(message, code: code, details: details);
  if (code == 'auth_unauthorized') return UnauthorizedFailure(message, code: code, details: details);
  if (code == 'auth_forbidden') return ForbiddenFailure(message, code: code, details: details);
  if (code == 'auth_phone_exists') return ResourceAlreadyExistsFailure(message, code: code, details: details);
  if (code == 'auth_phone_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'auth_invalid_refresh') return RefreshTokenFailure(message, code: code, details: details);
  if (code == 'auth_2fa_required') return TwoFactorRequiredFailure(message, code: code, details: details);
  if (code == 'auth_2fa_invalid') return ValidationFailure(message, code: code, details: details);
  if (code == 'auth_device_required') return UnauthorizedFailure(message, code: code, details: details);
  if (code == 'auth_device_session_expired') return DeviceSessionExpiredFailure(message, code: code, details: details);

  // ─────────────────── Validation ───────────────────
  if (code == 'validation_missing_field' ||
      code == 'validation_invalid_phone' ||
      code == 'validation_invalid_email' ||
      code == 'validation_invalid_amount' ||
      code == 'validation_invalid_currency' ||
      code == 'validation_invalid_language' ||
      code == 'validation_invalid_timezone' ||
      code == 'validation_invalid_uuid' ||
      code == 'validation_invalid_enum' ||
      code == 'validation_exceeds_max_length' ||
      code == 'validation_belows_min_length' ||
      code == 'validation_invalid_parameter') {
    return ValidationFailure(message, code: code, details: details);
  }
  if (code == 'validation_invalid_json' ||
      code == 'validation_invalid_content_type' ||
      code == 'validation_body_too_large') {
    return BadRequestFailure(message, code: code, details: details);
  }
  if (code == 'validation_idempotency_reuse') return ConflictFailure(message, code: code, details: details);

  // ─────────────────── Order ───────────────────
  if (code == 'order_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'order_already_paid' ||
      code == 'order_already_processed' ||
      code == 'order_invalid_status') {
    return OrderStateConflictFailure(message, code: code, details: details);
  }
  if (code == 'order_expired' || code == 'order_cancelled') {
    return ResourceExpiredFailure(message, code: code, details: details);
  }

  // ─────────────────── Plan ───────────────────
  if (code == 'plan_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'plan_unavailable' || code == 'plan_inactive') {
    return PlanUnavailableFailure(message, code: code, details: details);
  }
  if (code == 'plan_country_unsupported') return ValidationFailure(message, code: code, details: details);

  // ─────────────────── Wallet ───────────────────
  if (code == 'wallet_insufficient_balance' || code == 'wallet_insufficient_available') {
    return InsufficientBalanceFailure(message, code: code, details: details);
  }
  if (code == 'wallet_not_found' || code == 'wallet_freeze_not_found') {
    return NotFoundFailure(message, code: code, details: details);
  }
  if (code == 'wallet_transaction_failed') return ServerErrorFailure(message, code: code, details: details);
  if (code == 'wallet_freeze_exceeds_balance') return ValidationFailure(message, code: code, details: details);
  if (code == 'wallet_freeze_already_released') return ConflictFailure(message, code: code, details: details);

  // ─────────────────── Payment ───────────────────
  if (code == 'payment_failed' ||
      code == 'payment_refund_failed') {
    return ServerErrorFailure(message, code: code, details: details);
  }
  if (code == 'payment_timeout') return GatewayTimeoutFailure(message, code: code, details: details);
  if (code == 'payment_declined') return InsufficientBalanceFailure(message, code: code, details: details);
  if (code == 'payment_cancelled') return ResourceExpiredFailure(message, code: code, details: details);
  if (code == 'payment_invalid_signature') return UnauthorizedFailure(message, code: code, details: details);
  if (code == 'payment_duplicate') return ConflictFailure(message, code: code, details: details);
  if (code == 'payment_method_unsupported') return ValidationFailure(message, code: code, details: details);

  // ─────────────────── Provider ───────────────────
  if (code == 'provider_unavailable') return ServiceUnavailableFailure(message, code: code, details: details);
  if (code == 'provider_timeout') return GatewayTimeoutFailure(message, code: code, details: details);
  if (code == 'provider_invalid_response' ||
      code == 'provider_auth_failed') {
    return ServerErrorFailure(message, code: code, details: details);
  }
  if (code == 'provider_rate_limited') return RateLimitFailure(message, code: code, details: details);
  if (code == 'provider_insufficient_balance') return InsufficientBalanceFailure(message, code: code, details: details);
  if (code == 'provider_bundle_not_found') return NotFoundFailure(message, code: code, details: details);

  // ─────────────────── Rate Limit ───────────────────
  if (code == 'rate_limit_exceeded' || code == 'rate_limit_auth_exceeded') {
    return RateLimitFailure(message, code: code, details: details);
  }

  // ─────────────────── System ───────────────────
  if (code == 'internal_error' || code == 'database_error') {
    return ServerErrorFailure(message, code: code, details: details);
  }
  if (code == 'database_connection_error') return ServiceUnavailableFailure(message, code: code, details: details);
  if (code == 'database_integrity_error') return ConflictFailure(message, code: code, details: details);
  if (code == 'maintenance_mode') return MaintenanceModeFailure(message, code: code, details: details);

  // ─────────────────── User ───────────────────
  if (code == 'user_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'user_account_deleted') return AccountDisabledFailure(message, code: code, details: details);

  // ─────────────────── eSIM ───────────────────
  if (code == 'esim_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'esim_expired') return ResourceExpiredFailure(message, code: code, details: details);
  if (code == 'esim_invalid_status') return OrderStateConflictFailure(message, code: code, details: details);
  if (code == 'esim_order_failed' ||
      code == 'esim_apply_failed' ||
      code == 'esim_install_failed' ||
      code == 'esim_catalogue_failed') {
    return ServerErrorFailure(message, code: code, details: details);
  }
  if (code == 'esim_callback_invalid') return BadRequestFailure(message, code: code, details: details);

  // ─────────────────── Inventory ───────────────────
  if (code == 'inventory_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'inventory_insufficient_stock') return InsufficientStockFailure(message, code: code, details: details);
  if (code == 'inventory_iccid_duplicate') return ResourceAlreadyExistsFailure(message, code: code, details: details);
  if (code == 'inventory_invalid_file' || code == 'inventory_iccid_invalid') {
    return ValidationFailure(message, code: code, details: details);
  }

  // ─────────────────── Activation ───────────────────
  if (code == 'activation_failed' || code == 'activation_max_retries') {
    return ServerErrorFailure(message, code: code, details: details);
  }
  if (code == 'activation_timeout') return GatewayTimeoutFailure(message, code: code, details: details);

  // ─────────────────── Invoice / Coupon / Tax / Exchange Rate ───────────────────
  if (code == 'invoice_not_found' ||
      code == 'coupon_not_found' ||
      code == 'tax_not_found' ||
      code == 'exchange_rate_not_found') {
    return NotFoundFailure(message, code: code, details: details);
  }
  if (code == 'coupon_expired' ||
      code == 'coupon_exhausted' ||
      code == 'tax_inactive') {
    return ResourceExpiredFailure(message, code: code, details: details);
  }
  if (code == 'coupon_invalid_for_plan' ||
      code == 'coupon_min_order_not_met' ||
      code == 'exchange_rate_invalid') {
    return ValidationFailure(message, code: code, details: details);
  }
  if (code == 'coupon_already_used' || code == 'invalid_state') {
    return ConflictFailure(message, code: code, details: details);
  }

  // ─────────────────── Refund ───────────────────
  if (code == 'refund_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'refund_invalid_amount') return ValidationFailure(message, code: code, details: details);
  if (code == 'refund_exceeds_order') return RefundExceedsAmountFailure(message, code: code, details: details);
  if (code == 'refund_order_not_paid') return OrderStateConflictFailure(message, code: code, details: details);

  // ─────────────────── Report ───────────────────
  if (code == 'report_invalid_period') return ValidationFailure(message, code: code, details: details);

  // ─────────────────── Payment Provider (ZainCash / QiCard) ───────────────────
  if (code == 'zaincash_init_failed' ||
      code == 'qicard_init_failed' ||
      code == 'qicard_verification_failed' ||
      code == 'qicard_cancel_failed' ||
      code == 'qicard_refund_failed') {
    return ServerErrorFailure(message, code: code, details: details);
  }
  if (code == 'zaincash_callback_invalid' ||
      code == 'qicard_webhook_invalid') {
    return BadRequestFailure(message, code: code, details: details);
  }
  if (code == 'zaincash_transaction_not_found' ||
      code == 'qicard_transaction_not_found') {
    return NotFoundFailure(message, code: code, details: details);
  }

  // ─────────────────── SMS ───────────────────
  if (code == 'sms_init_failed' ||
      code == 'sms_send_failed' ||
      code == 'sms_provider_auth_failed') {
    return ServerErrorFailure(message, code: code, details: details);
  }
  if (code == 'sms_provider_balance_low') return InsufficientBalanceFailure(message, code: code, details: details);
  if (code == 'sms_otp_verification_failed') return BadRequestFailure(message, code: code, details: details);

  // ─────────────────── Support Tickets ───────────────────
  if (code == 'support_ticket_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'support_ticket_closed' ||
      code == 'support_cannot_assign_to_self') {
    return ConflictFailure(message, code: code, details: details);
  }
  if (code == 'support_ticket_access_denied') return ForbiddenFailure(message, code: code, details: details);
  if (code == 'support_message_empty') return ValidationFailure(message, code: code, details: details);

  // ─────────────────── Referral ───────────────────
  if (code == 'referral_code_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'referral_code_invalid') return ValidationFailure(message, code: code, details: details);
  if (code == 'referral_self_referral' ||
      code == 'referral_already_referred' ||
      code == 'referral_not_qualified') {
    return ConflictFailure(message, code: code, details: details);
  }
  if (code == 'feature_disabled') return ForbiddenFailure(message, code: code, details: details);

  // ─────────────────── Generic ───────────────────
  if (code == 'not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'method_not_allowed') return BadRequestFailure(message, code: code, details: details);

  // ─────────────────── Settings ───────────────────
  if (code == 'setting_not_found') return NotFoundFailure(message, code: code, details: details);
  if (code == 'setting_key_exists') return ResourceAlreadyExistsFailure(message, code: code, details: details);
  if (code == 'admin_cannot_modify_self') return ValidationFailure(message, code: code, details: details);

  // ─────────────────── Import ───────────────────
  if (code == 'import_invalid_format') return ValidationFailure(message, code: code, details: details);

  // ── Fallback by statusCode ──
  if (statusCode != null) {
    if (statusCode == 400) return BadRequestFailure(message, code: code, details: details);
    if (statusCode == 401) return UnauthorizedFailure(message, code: code, details: details);
    if (statusCode == 402) return InsufficientBalanceFailure(message, code: code, details: details);
    if (statusCode == 403) return ForbiddenFailure(message, code: code, details: details);
    if (statusCode == 404) return NotFoundFailure(message, code: code, details: details);
    if (statusCode == 409) return ConflictFailure(message, code: code, details: details);
    if (statusCode == 410) return ResourceExpiredFailure(message, code: code, details: details);
    if (statusCode == 413) return BadRequestFailure(message, code: code, details: details);
    if (statusCode == 415) return BadRequestFailure(message, code: code, details: details);
    if (statusCode == 422) return ValidationFailure(message, code: code, details: details, fieldErrors: fieldErrors);
    if (statusCode == 423) return AccountLockedFailure(message, code: code, details: details);
    if (statusCode == 429) return RateLimitFailure(message, code: code, details: details);
    if (statusCode >= 500) return ServerErrorFailure(message, code: code, details: details);
  }

  return UnknownServerFailure(message, code: code, details: details, statusCode: statusCode);
}

// ────────────────────────────────────────────
// 3. NETWORK EXCEPTION → Failure mapper
// ────────────────────────────────────────────
Failure mapNetworkErrorToFailure(dynamic error) {
  final msg = error.toString();

  if (error is SocketException) {
    if (msg.contains('timed out') || msg.contains('timeout')) {
      return ConnectionTimeoutFailure('Connection timed out. Please check your internet.', details: msg);
    }
    if (msg.contains('refused')) {
      return ConnectionRefusedFailure('Connection refused by server.', details: msg);
    }
    if (msg.contains('unreachable') || msg.contains('No address')) {
      return HostUnreachableFailure('Server is unreachable.', details: msg);
    }
    return UnknownNetworkFailure('Network error occurred.', details: msg);
  }

  if (error is HttpException) {
    return UnknownNetworkFailure('HTTP error occurred.', details: msg);
  }

  if (msg.contains('TimeoutException') || msg.contains('timed out')) {
    return ConnectionTimeoutFailure('Connection timed out. Please check your internet.', details: msg);
  }

  if (msg.contains('HandshakeException') || msg.contains('SSL') || msg.contains('certificate')) {
    return SslFailure('SSL connection error.', details: msg);
  }

  if (msg.contains('No address') || msg.contains('unreachable')) {
    return HostUnreachableFailure('Server is unreachable.', details: msg);
  }

  if (msg.contains('Connection refused')) {
    return ConnectionRefusedFailure('Connection refused by server.', details: msg);
  }

  return UnknownNetworkFailure('An unknown network error occurred.', details: msg);
}

// ────────────────────────────────────────────
// 4. DISPLAY helpers
// ────────────────────────────────────────────
void showSuccessNotification(BuildContext context, String message) {
  CustomToaster.showSuccess(
    context,
    title: trans(context, 'Success'),
    message: trans(context, message),
  );
}

void showErrorNotification(BuildContext context, String message) {
  CustomToaster.showError(
    context,
    title: trans(context, 'Error'),
    message: trans(context, message),
  );
}

void showNotificationSnackbar(BuildContext context, String message, {bool isError = true}) {
  if (isError) {
    showErrorNotification(context, message);
  } else {
    showSuccessNotification(context, message);
  }
}

// ────────────────────────────────────────────
// 5. MAIN handler: Failure → UI
// ────────────────────────────────────────────
void handleFailure(BuildContext context, Failure failure) {
  // ── Specialised handling per failure type ──
  if (failure is SessionExpiredFailure || failure is DeviceSessionExpiredFailure) {
    showErrorNotification(context, failure.message);
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const _LoginRedirectWidget()),
          (route) => false,
        );
      }
    });
    return;
  }

  if (failure is MaintenanceModeFailure) {
    showErrorNotification(context, failure.message);
    // Could show a special maintenance dialog here
    return;
  }

  if (failure is TwoFactorRequiredFailure) {
    // Handled by caller opening 2FA dialog; show generic notification
    showErrorNotification(context, failure.message);
    return;
  }

  if (failure is ValidationFailure && failure.fieldErrors != null && failure.fieldErrors!.isNotEmpty) {
    final firstField = failure.fieldErrors!.entries.first;
    final firstError = firstField.value.isNotEmpty ? firstField.value.first : failure.message;
    showErrorNotification(context, firstError);
    return;
  }

  if (failure is RateLimitFailure) {
    final retryMsg = failure.retryAfterSeconds != null
        ? '${failure.message} (retry after ${failure.retryAfterSeconds}s)'
        : failure.message;
    showErrorNotification(context, retryMsg);
    return;
  }

  if (failure is ImportFailure) {
    final parts = <String>[failure.message];
    if (failure.successCount != null) parts.add('Success: ${failure.successCount}');
    if (failure.failureCount != null) parts.add('Failed: ${failure.failureCount}');
    showErrorNotification(context, parts.join(' | '));
    return;
  }

  if (failure is NoInternetFailure) {
    showErrorNotification(context, failure.message);
    return;
  }

  // ── Default: show the failure message ──
  showErrorNotification(context, failure.message);
}

// ────────────────────────────────────────────
// 6. Convenience: ApiServiceException → UI
// ────────────────────────────────────────────
void handleApiServiceError(BuildContext context, dynamic error) {
  String message;
  bool isError = true;

  if (error is Failure) {
    handleFailure(context, error);
    return;
  }

  if (error is Exception) {
    final errorStr = error.toString();
    if (errorStr.contains('No internet') || errorStr.contains('SocketException')) {
      message = 'No internet connection available.';
    } else if (errorStr.contains('timed out') || errorStr.contains('TimeoutException')) {
      message = 'Connection timed out. Please check your internet.';
    } else {
      message = 'An error occurred. Please try again.';
    }
  } else {
    message = 'An unexpected error occurred.';
  }

  showNotificationSnackbar(context, message, isError: isError);
}

class _LoginRedirectWidget extends StatelessWidget {
  const _LoginRedirectWidget();

  @override
  Widget build(BuildContext context) {
    return const PhoneEntryScreen();
  }
}
