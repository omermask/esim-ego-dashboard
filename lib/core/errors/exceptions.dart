/// Base exception for structured error info from server
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final String? details;
  final Map<String, List<String>>? fieldErrors;

  ServerException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
    this.fieldErrors,
  });

  @override
  String toString() => 'ServerException($statusCode): $message [$code]';
}

/// Exception wrapping an ApiException from the HTTP layer
class ApiServiceException implements Exception {
  final String message;
  final int status;
  final String code;
  final dynamic rawMessage;

  const ApiServiceException({
    required this.message,
    required this.status,
    required this.code,
    this.rawMessage,
  });

  @override
  String toString() => 'ApiServiceException($status): $message [$code]';
}

/// Network-level exception
class NetworkException implements Exception {
  final String message;
  final String? type;

  const NetworkException({required this.message, this.type});

  factory NetworkException.noInternet() => const NetworkException(
        message: 'No internet connection available.',
        type: 'NO_INTERNET',
      );
  factory NetworkException.timeout() => const NetworkException(
        message: 'Connection timeout. Please check your internet.',
        type: 'TIMEOUT',
      );
  factory NetworkException.connectionRefused() => const NetworkException(
        message: 'Connection refused by server.',
        type: 'CONNECTION_REFUSED',
      );
  factory NetworkException.hostUnreachable() => const NetworkException(
        message: 'Server is unreachable.',
        type: 'HOST_UNREACHABLE',
      );
  factory NetworkException.sslError() => const NetworkException(
        message: 'SSL handshake failed.',
        type: 'SSL_ERROR',
      );

  @override
  String toString() => 'NetworkException($type): $message';
}

/// Cache/storage exception
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Local validation exception (before sending to server)
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  const ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

/// Maintenance mode exception
class MaintenanceException implements Exception {
  final String message;
  final String? expectedResolution;
  const MaintenanceException({required this.message, this.expectedResolution});

  @override
  String toString() => 'MaintenanceException: $message';
}
