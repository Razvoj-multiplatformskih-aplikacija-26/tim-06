
import 'package:domain/src/errors.dart';
import 'package:meta/meta.dart';

sealed class Result<T>{
  const Result();

  T? get valueOrNull => switch(this){
    Success(:final value) => value,
    Failure() => null,
  };

  DomainError? get errorOrNull => switch(this){
    Success() => null,
    Failure(:final error) => error,
  };

  bool get isSucces => this is Success<T>;
}

@immutable
final class Success<T> extends Result<T>{
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
          other is Success &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

final class Failure<T> extends Result<T>{
  final DomainError error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
          other is Failure &&
              error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';

}