sealed class Result<T> {
  const Result();
  factory Result.success(T value) = Success<T>;
  factory Result.failure(Exception exception) = Failure<T>;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final Exception exception;
  const Failure(this.exception);
}   