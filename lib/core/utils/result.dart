import 'package:freezed_annotation/freezed_annotation.dart';

import '../errors/failures.dart';

part 'result.freezed.dart';

/// A Result type that represents either a success or a failure
/// Similar to Either in functional programming
@freezed
class Result<T> with _$Result<T> {
  const Result._();

  /// Successful result with data
  const factory Result.success(T data) = Success<T>;

  /// Failed result with failure details
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  /// Check if result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if result is a failure
  bool get isFailure => this is ResultFailure<T>;

  /// Get data or null if failure
  T? get dataOrNull => whenOrNull(success: (data) => data);

  /// Get failure or null if success
  Failure? get failureOrNull => whenOrNull(failure: (failure) => failure);

  /// Get data or throw if failure
  T get dataOrThrow => when(
        success: (data) => data,
        failure: (failure) => throw failure,
      );

  /// Get data or return default value
  T dataOr(T defaultValue) => when(
        success: (data) => data,
        failure: (_) => defaultValue,
      );

  /// Map the success value
  Result<R> mapSuccess<R>(R Function(T data) mapper) => when(
        success: (data) => Result.success(mapper(data)),
        failure: (failure) => Result.failure(failure),
      );

  /// Flat map the success value
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) => when(
        success: (data) => mapper(data),
        failure: (failure) => Result.failure(failure),
      );

  /// Execute callback on success
  Result<T> onSuccess(void Function(T data) callback) {
    whenOrNull(success: callback);
    return this;
  }

  /// Execute callback on failure
  Result<T> onFailure(void Function(Failure failure) callback) {
    whenOrNull(failure: callback);
    return this;
  }

  /// Convert to async result
  Future<Result<T>> toFuture() => Future.value(this);
}

/// Extension for creating results from futures
extension FutureResultExtension<T> on Future<T> {
  /// Convert a future to a Result, catching any errors
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } on Failure catch (failure) {
      return Result.failure(failure);
    } catch (e, stackTrace) {
      return Result.failure(
        Failure.unknown(
          message: e.toString(),
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Extension for combining results
extension ResultListExtension<T> on List<Result<T>> {
  /// Combine all results into a single result with a list
  /// Returns failure if any result is a failure
  Result<List<T>> combine() {
    final List<T> successes = [];

    for (final result in this) {
      final failure = result.failureOrNull;
      if (failure != null) {
        return Result.failure(failure);
      }
      successes.add(result.dataOrThrow);
    }

    return Result.success(successes);
  }

  /// Get all successful values, ignoring failures
  List<T> get successes => map((r) => r.dataOrNull).whereType<T>().toList();

  /// Get all failures, ignoring successes
  List<Failure> get failures =>
      map((r) => r.failureOrNull).whereType<Failure>().toList();
}
