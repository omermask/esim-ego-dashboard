abstract class Failure {
  final String message;
  final String? code;
  final String? details;
  DateTime get timestamp => DateTime(0);

  const Failure(this.message, {this.code, this.details});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

// ── Server Failures (HTTP Status based) ──
class BadRequestFailure extends Failure {
  const BadRequestFailure(super.message, {super.code, super.details});
}
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.code, super.details});
}
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.code, super.details});
}
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.details});
}
class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code, super.details});
}
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure(super.message, {super.code, super.details, this.fieldErrors});
}
class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;
  const RateLimitFailure(super.message, {super.code, super.details, this.retryAfterSeconds});
}
class ServerErrorFailure extends Failure {
  const ServerErrorFailure(super.message, {super.code, super.details});
}
class ServiceUnavailableFailure extends Failure {
  const ServiceUnavailableFailure(super.message, {super.code, super.details});
}
class GatewayTimeoutFailure extends Failure {
  const GatewayTimeoutFailure(super.message, {super.code, super.details});
}
class UnknownServerFailure extends Failure {
  final int? statusCode;
  const UnknownServerFailure(super.message, {super.code, super.details, this.statusCode});
}

// ── Network Failures ──
class NoInternetFailure extends Failure {
  const NoInternetFailure(super.message, {super.code, super.details});
}
class ConnectionTimeoutFailure extends Failure {
  const ConnectionTimeoutFailure(super.message, {super.code, super.details});
}
class ConnectionRefusedFailure extends Failure {
  const ConnectionRefusedFailure(super.message, {super.code, super.details});
}
class HostUnreachableFailure extends Failure {
  const HostUnreachableFailure(super.message, {super.code, super.details});
}
class SslFailure extends Failure {
  const SslFailure(super.message, {super.code, super.details});
}
class UnknownNetworkFailure extends Failure {
  const UnknownNetworkFailure(super.message, {super.code, super.details});
}

// ── Auth Flow Failures ──
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure(super.message, {super.code, super.details});
}
class DeviceSessionExpiredFailure extends Failure {
  const DeviceSessionExpiredFailure(super.message, {super.code, super.details});
}
class RefreshTokenFailure extends Failure {
  const RefreshTokenFailure(super.message, {super.code, super.details});
}
class TwoFactorRequiredFailure extends Failure {
  const TwoFactorRequiredFailure(super.message, {super.code, super.details});
}
class AccountLockedFailure extends Failure {
  const AccountLockedFailure(super.message, {super.code, super.details});
}
class AccountDisabledFailure extends Failure {
  const AccountDisabledFailure(super.message, {super.code, super.details});
}

// ── Business Logic Failures ──
class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure(super.message, {super.code, super.details});
}
class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure(super.message, {super.code, super.details});
}
class OrderStateConflictFailure extends Failure {
  const OrderStateConflictFailure(super.message, {super.code, super.details});
}
class RefundExceedsAmountFailure extends Failure {
  const RefundExceedsAmountFailure(super.message, {super.code, super.details});
}
class WalletFrozenFailure extends Failure {
  const WalletFrozenFailure(super.message, {super.code, super.details});
}
class PlanUnavailableFailure extends Failure {
  const PlanUnavailableFailure(super.message, {super.code, super.details});
}
class ResourceAlreadyExistsFailure extends Failure {
  const ResourceAlreadyExistsFailure(super.message, {super.code, super.details});
}
class ResourceExpiredFailure extends Failure {
  const ResourceExpiredFailure(super.message, {super.code, super.details});
}

// ── System Failures ──
class MaintenanceModeFailure extends Failure {
  final String? expectedResolution;
  const MaintenanceModeFailure(super.message, {super.code, super.details, this.expectedResolution});
}
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.details});
}
class ImportFailure extends Failure {
  final int? successCount;
  final int? failureCount;
  const ImportFailure(super.message, {super.code, super.details, this.successCount, this.failureCount});
}
