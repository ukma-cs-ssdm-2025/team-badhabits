/// Base exception class
class ServerException implements Exception {
  const ServerException(this.message);

  final String message;

  @override
  String toString() => 'ServerException: $message';
}

/// Cache exception
class CacheException implements Exception {
  const CacheException(this.message);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

/// Network exception
class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Validation exception
class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
