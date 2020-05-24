// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_signal.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LocationsSignal extends Equatable {
  const LocationsSignal(this._type);

  factory LocationsSignal.loading({@required String message}) = Loading;

  factory LocationsSignal.loadingError({@required String message}) =
      LoadingError;

  final _LocationsSignal _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Loading) loading,
      @required R Function(LoadingError) loadingError}) {
    assert(() {
      if (loading == null || loadingError == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsSignal.Loading:
        return loading(this as Loading);
      case _LocationsSignal.LoadingError:
        return loadingError(this as LoadingError);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Loading) loading,
      @required FutureOr<R> Function(LoadingError) loadingError}) {
    assert(() {
      if (loading == null || loadingError == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsSignal.Loading:
        return loading(this as Loading);
      case _LocationsSignal.LoadingError:
        return loadingError(this as LoadingError);
    }
  }

  R whenOrElse<R>(
      {R Function(Loading) loading,
      R Function(LoadingError) loadingError,
      @required R Function(LocationsSignal) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsSignal.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _LocationsSignal.LoadingError:
        if (loadingError == null) break;
        return loadingError(this as LoadingError);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Loading) loading,
      FutureOr<R> Function(LoadingError) loadingError,
      @required FutureOr<R> Function(LocationsSignal) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsSignal.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _LocationsSignal.LoadingError:
        if (loadingError == null) break;
        return loadingError(this as LoadingError);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Loading) loading,
      FutureOr<void> Function(LoadingError) loadingError}) {
    assert(() {
      if (loading == null && loadingError == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsSignal.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _LocationsSignal.LoadingError:
        if (loadingError == null) break;
        return loadingError(this as LoadingError);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Loading extends LocationsSignal {
  const Loading({@required this.message}) : super(_LocationsSignal.Loading);

  final String message;

  @override
  String toString() => 'Loading(message:${this.message})';
  @override
  List get props => [message];
}

@immutable
class LoadingError extends LocationsSignal {
  const LoadingError({@required this.message})
      : super(_LocationsSignal.LoadingError);

  final String message;

  @override
  String toString() => 'LoadingError(message:${this.message})';
  @override
  List get props => [message];
}
