/// Core data layer exceptions.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException([
    this.message = 'Server encountered an error.',
    this.statusCode,
  ]);

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([
    this.message = 'Network connection is unavailable or timed out.',
  ]);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache read/write operation failed.']);

  @override
  String toString() => 'CacheException: $message';
}
