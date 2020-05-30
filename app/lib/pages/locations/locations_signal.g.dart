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

  factory LocationsSignal.loadedSuccessfully() = LoadedSuccessfully;

  final _LocationsSignal _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Loading) loading,
      @required R Function(LoadingError) loadingError,
      @required R Function(LoadedSuccessfully) loadedSuccessfully}) {
    assert(() {
      if (loading == null ||
          loadingError == null ||
          loadedSuccessfully == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsSignal.Loading:
        return loading(this as Loading);
      case _LocationsSignal.LoadingError:
        return loadingError(this as LoadingError);
      case _LocationsSignal.LoadedSuccessfully:
        return loadedSuccessfully(this as LoadedSuccessfully);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Loading) loading,
      @required FutureOr<R> Function(LoadingError) loadingError,
      @required FutureOr<R> Function(LoadedSuccessfully) loadedSuccessfully}) {
    assert(() {
      if (loading == null ||
          loadingError == null ||
          loadedSuccessfully == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsSignal.Loading:
        return loading(this as Loading);
      case _LocationsSignal.LoadingError:
        return loadingError(this as LoadingError);
      case _LocationsSignal.LoadedSuccessfully:
        return loadedSuccessfully(this as LoadedSuccessfully);
    }
  }

  R whenOrElse<R>(
      {R Function(Loading) loading,
      R Function(LoadingError) loadingError,
      R Function(LoadedSuccessfully) loadedSuccessfully,
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
      case _LocationsSignal.LoadedSuccessfully:
        if (loadedSuccessfully == null) break;
        return loadedSuccessfully(this as LoadedSuccessfully);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Loading) loading,
      FutureOr<R> Function(LoadingError) loadingError,
      FutureOr<R> Function(LoadedSuccessfully) loadedSuccessfully,
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
      case _LocationsSignal.LoadedSuccessfully:
        if (loadedSuccessfully == null) break;
        return loadedSuccessfully(this as LoadedSuccessfully);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Loading) loading,
      FutureOr<void> Function(LoadingError) loadingError,
      FutureOr<void> Function(LoadedSuccessfully) loadedSuccessfully}) {
    assert(() {
      if (loading == null &&
          loadingError == null &&
          loadedSuccessfully == null) {
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
      case _LocationsSignal.LoadedSuccessfully:
        if (loadedSuccessfully == null) break;
        return loadedSuccessfully(this as LoadedSuccessfully);
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

@immutable
class LoadedSuccessfully extends LocationsSignal {
  const LoadedSuccessfully._() : super(_LocationsSignal.LoadedSuccessfully);

  factory LoadedSuccessfully() {
    _instance ??= const LoadedSuccessfully._();
    return _instance;
  }

  static LoadedSuccessfully _instance;
}
