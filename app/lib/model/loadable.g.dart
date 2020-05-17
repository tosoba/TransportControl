// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loadable.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class Loadable<T> extends Equatable {
  const Loadable(this._type);

  factory Loadable.loading() = Loading<T>;

  factory Loadable.value({@required T value}) = Value<T>;

  factory Loadable.error({@required dynamic error}) = Error<T>;

  final _Loadable _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Loading<T>) loading,
      @required R Function(Value<T>) value,
      @required R Function(Error<T>) error}) {
    assert(() {
      if (loading == null || value == null || error == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _Loadable.Loading:
        return loading(this as Loading);
      case _Loadable.Value:
        return value(this as Value);
      case _Loadable.Error:
        return error(this as Error);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Loading<T>) loading,
      @required FutureOr<R> Function(Value<T>) value,
      @required FutureOr<R> Function(Error<T>) error}) {
    assert(() {
      if (loading == null || value == null || error == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _Loadable.Loading:
        return loading(this as Loading);
      case _Loadable.Value:
        return value(this as Value);
      case _Loadable.Error:
        return error(this as Error);
    }
  }

  R whenOrElse<R>(
      {R Function(Loading<T>) loading,
      R Function(Value<T>) value,
      R Function(Error<T>) error,
      @required R Function(Loadable<T>) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _Loadable.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _Loadable.Value:
        if (value == null) break;
        return value(this as Value);
      case _Loadable.Error:
        if (error == null) break;
        return error(this as Error);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Loading<T>) loading,
      FutureOr<R> Function(Value<T>) value,
      FutureOr<R> Function(Error<T>) error,
      @required FutureOr<R> Function(Loadable<T>) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _Loadable.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _Loadable.Value:
        if (value == null) break;
        return value(this as Value);
      case _Loadable.Error:
        if (error == null) break;
        return error(this as Error);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Loading<T>) loading,
      FutureOr<void> Function(Value<T>) value,
      FutureOr<void> Function(Error<T>) error}) {
    assert(() {
      if (loading == null && value == null && error == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _Loadable.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _Loadable.Value:
        if (value == null) break;
        return value(this as Value);
      case _Loadable.Error:
        if (error == null) break;
        return error(this as Error);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Loading<T> extends Loadable<T> {
  const Loading._() : super(_Loadable.Loading);

  factory Loading() {
    _instance ??= const Loading._();
    return _instance;
  }

  static Loading _instance;
}

@immutable
class Value<T> extends Loadable<T> {
  const Value({@required this.value}) : super(_Loadable.Value);

  final T value;

  @override
  String toString() => 'Value(value:${this.value})';
  @override
  List get props => [value];
}

@immutable
class Error<T> extends Loadable<T> {
  const Error({@required this.error}) : super(_Loadable.Error);

  final dynamic error;

  @override
  String toString() => 'Error(error:${this.error})';
  @override
  List get props => [error];
}
