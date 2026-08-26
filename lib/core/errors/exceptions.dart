/// Low-level exceptions thrown by data sources. These are caught by
/// repositories and mapped to [Failure]s — they must never leak into the
/// presentation layer.
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No network connection.']);
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Server error.', this.statusCode]);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local cache error.']);
}

class AiParsingException implements Exception {
  final String message;
  const AiParsingException([this.message = 'Malformed AI response.']);
}

class AiTimeoutException implements Exception {
  final String message;
  const AiTimeoutException([this.message = 'AI request timed out.']);
}

class AiRateLimitException implements Exception {
  final String message;
  const AiRateLimitException([this.message = 'AI request was rate limited.']);
}

class SubscriptionException implements Exception {
  final String message;
  const SubscriptionException([this.message = 'Subscription operation failed.']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Requested item was not found.']);
}
