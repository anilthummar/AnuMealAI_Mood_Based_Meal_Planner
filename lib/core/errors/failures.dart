import 'package:equatable/equatable.dart';

/// Base type for all user-facing failures. Every failure carries a
/// human-friendly [message] — never a raw stack trace or provider error.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "You're offline. Check your connection and try again."]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = "Something went wrong on our end. Please try again."]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = "We couldn't load your saved data."]);
}

class AiGenerationFailure extends Failure {
  const AiGenerationFailure([super.message = "We couldn't come up with meal ideas right now."]);
}

class AiParsingFailure extends Failure {
  const AiParsingFailure([super.message = "We received an unexpected response. Please try again."]);
}

class AiRateLimitFailure extends Failure {
  const AiRateLimitFailure([super.message = "You're generating ideas a little too fast. Give it a moment."]);
}

class SubscriptionFailure extends Failure {
  const SubscriptionFailure([super.message = "We couldn't complete that purchase action."]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UsageLimitFailure extends Failure {
  const UsageLimitFailure([super.message = "You've reached today's limit."]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = "Something unexpected happened. Please try again."]);
}
