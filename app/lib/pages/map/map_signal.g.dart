// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_signal.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapSignal extends Equatable {
  const MapSignal(this._type);

  factory MapSignal.loading({@required String message}) = Loading;

  factory MapSignal.loadedSuccessfully() = LoadedSuccessfully;

  factory MapSignal.zoomToBoundsAfterLoadedSuccessfully(
      {@required LatLngBounds bounds}) = ZoomToBoundsAfterLoadedSuccessfully;

  factory MapSignal.loadingError({@required String message}) = LoadingError;

  final _MapSignal _type;

//ignore: missing_return
  R when<R>(
      {@required
          R Function(Loading) loading,
      @required
          R Function(LoadedSuccessfully) loadedSuccessfully,
      @required
          R Function(ZoomToBoundsAfterLoadedSuccessfully)
              zoomToBoundsAfterLoadedSuccessfully,
      @required
          R Function(LoadingError) loadingError}) {
    assert(() {
      if (loading == null ||
          loadedSuccessfully == null ||
          zoomToBoundsAfterLoadedSuccessfully == null ||
          loadingError == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSignal.Loading:
        return loading(this as Loading);
      case _MapSignal.LoadedSuccessfully:
        return loadedSuccessfully(this as LoadedSuccessfully);
      case _MapSignal.ZoomToBoundsAfterLoadedSuccessfully:
        return zoomToBoundsAfterLoadedSuccessfully(
            this as ZoomToBoundsAfterLoadedSuccessfully);
      case _MapSignal.LoadingError:
        return loadingError(this as LoadingError);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(Loading) loading,
      @required
          FutureOr<R> Function(LoadedSuccessfully) loadedSuccessfully,
      @required
          FutureOr<R> Function(ZoomToBoundsAfterLoadedSuccessfully)
              zoomToBoundsAfterLoadedSuccessfully,
      @required
          FutureOr<R> Function(LoadingError) loadingError}) {
    assert(() {
      if (loading == null ||
          loadedSuccessfully == null ||
          zoomToBoundsAfterLoadedSuccessfully == null ||
          loadingError == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSignal.Loading:
        return loading(this as Loading);
      case _MapSignal.LoadedSuccessfully:
        return loadedSuccessfully(this as LoadedSuccessfully);
      case _MapSignal.ZoomToBoundsAfterLoadedSuccessfully:
        return zoomToBoundsAfterLoadedSuccessfully(
            this as ZoomToBoundsAfterLoadedSuccessfully);
      case _MapSignal.LoadingError:
        return loadingError(this as LoadingError);
    }
  }

  R whenOrElse<R>(
      {R Function(Loading) loading,
      R Function(LoadedSuccessfully) loadedSuccessfully,
      R Function(ZoomToBoundsAfterLoadedSuccessfully)
          zoomToBoundsAfterLoadedSuccessfully,
      R Function(LoadingError) loadingError,
      @required R Function(MapSignal) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSignal.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _MapSignal.LoadedSuccessfully:
        if (loadedSuccessfully == null) break;
        return loadedSuccessfully(this as LoadedSuccessfully);
      case _MapSignal.ZoomToBoundsAfterLoadedSuccessfully:
        if (zoomToBoundsAfterLoadedSuccessfully == null) break;
        return zoomToBoundsAfterLoadedSuccessfully(
            this as ZoomToBoundsAfterLoadedSuccessfully);
      case _MapSignal.LoadingError:
        if (loadingError == null) break;
        return loadingError(this as LoadingError);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Loading) loading,
      FutureOr<R> Function(LoadedSuccessfully) loadedSuccessfully,
      FutureOr<R> Function(ZoomToBoundsAfterLoadedSuccessfully)
          zoomToBoundsAfterLoadedSuccessfully,
      FutureOr<R> Function(LoadingError) loadingError,
      @required FutureOr<R> Function(MapSignal) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSignal.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _MapSignal.LoadedSuccessfully:
        if (loadedSuccessfully == null) break;
        return loadedSuccessfully(this as LoadedSuccessfully);
      case _MapSignal.ZoomToBoundsAfterLoadedSuccessfully:
        if (zoomToBoundsAfterLoadedSuccessfully == null) break;
        return zoomToBoundsAfterLoadedSuccessfully(
            this as ZoomToBoundsAfterLoadedSuccessfully);
      case _MapSignal.LoadingError:
        if (loadingError == null) break;
        return loadingError(this as LoadingError);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Loading) loading,
      FutureOr<void> Function(LoadedSuccessfully) loadedSuccessfully,
      FutureOr<void> Function(ZoomToBoundsAfterLoadedSuccessfully)
          zoomToBoundsAfterLoadedSuccessfully,
      FutureOr<void> Function(LoadingError) loadingError}) {
    assert(() {
      if (loading == null &&
          loadedSuccessfully == null &&
          zoomToBoundsAfterLoadedSuccessfully == null &&
          loadingError == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSignal.Loading:
        if (loading == null) break;
        return loading(this as Loading);
      case _MapSignal.LoadedSuccessfully:
        if (loadedSuccessfully == null) break;
        return loadedSuccessfully(this as LoadedSuccessfully);
      case _MapSignal.ZoomToBoundsAfterLoadedSuccessfully:
        if (zoomToBoundsAfterLoadedSuccessfully == null) break;
        return zoomToBoundsAfterLoadedSuccessfully(
            this as ZoomToBoundsAfterLoadedSuccessfully);
      case _MapSignal.LoadingError:
        if (loadingError == null) break;
        return loadingError(this as LoadingError);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Loading extends MapSignal {
  const Loading({@required this.message}) : super(_MapSignal.Loading);

  final String message;

  @override
  String toString() => 'Loading(message:${this.message})';
  @override
  List get props => [message];
}

@immutable
class LoadedSuccessfully extends MapSignal {
  const LoadedSuccessfully._() : super(_MapSignal.LoadedSuccessfully);

  factory LoadedSuccessfully() {
    _instance ??= const LoadedSuccessfully._();
    return _instance;
  }

  static LoadedSuccessfully _instance;
}

@immutable
class ZoomToBoundsAfterLoadedSuccessfully extends MapSignal {
  const ZoomToBoundsAfterLoadedSuccessfully({@required this.bounds})
      : super(_MapSignal.ZoomToBoundsAfterLoadedSuccessfully);

  final LatLngBounds bounds;

  @override
  String toString() =>
      'ZoomToBoundsAfterLoadedSuccessfully(bounds:${this.bounds})';
  @override
  List get props => [bounds];
}

@immutable
class LoadingError extends MapSignal {
  const LoadingError({@required this.message}) : super(_MapSignal.LoadingError);

  final String message;

  @override
  String toString() => 'LoadingError(message:${this.message})';
  @override
  List get props => [message];
}
