// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class Result<T> extends Equatable {
  const Result(this._type);

  factory Result.success({@required T data}) = Success<T>;

  factory Result.failure({@required dynamic error}) = Failure<T>;

  final _Result _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Success<T>) success,
      @required R Function(Failure<T>) failure}) {
    assert(() {
      if (success == null || failure == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _Result.Success:
        return success(this as Success);
      case _Result.Failure:
        return failure(this as Failure);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Success<T>) success,
      @required FutureOr<R> Function(Failure<T>) failure}) {
    assert(() {
      if (success == null || failure == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _Result.Success:
        return success(this as Success);
      case _Result.Failure:
        return failure(this as Failure);
    }
  }

  R whenOrElse<R>(
      {R Function(Success<T>) success,
      R Function(Failure<T>) failure,
      @required R Function(Result<T>) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _Result.Success:
        if (success == null) break;
        return success(this as Success);
      case _Result.Failure:
        if (failure == null) break;
        return failure(this as Failure);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Success<T>) success,
      FutureOr<R> Function(Failure<T>) failure,
      @required FutureOr<R> Function(Result<T>) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _Result.Success:
        if (success == null) break;
        return success(this as Success);
      case _Result.Failure:
        if (failure == null) break;
        return failure(this as Failure);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Success<T>) success,
      FutureOr<void> Function(Failure<T>) failure}) {
    assert(() {
      if (success == null && failure == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _Result.Success:
        if (success == null) break;
        return success(this as Success);
      case _Result.Failure:
        if (failure == null) break;
        return failure(this as Failure);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Success<T> extends Result<T> {
  const Success({@required this.data}) : super(_Result.Success);

  final T data;

  @override
  String toString() => 'Success(data:${this.data})';
  @override
  List get props => [data];
}

@immutable
class Failure<T> extends Result<T> {
  const Failure({@required this.error}) : super(_Result.Failure);

  final dynamic error;

  @override
  String toString() => 'Failure(error:${this.error})';
  @override
  List get props => [error];
}
