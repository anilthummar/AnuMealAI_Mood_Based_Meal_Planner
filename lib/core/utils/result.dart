import 'package:anu_meal_ai/core/errors/failures.dart';

/// Minimal Either-style result type so use cases/repositories can return
/// success-or-[Failure] without introducing an extra functional-programming
/// dependency. Deliberately small: [isSuccess]/[isFailure]/[fold] cover every
/// call site in this codebase.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Error<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Error<T>(:final failure) => failure,
      };

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
