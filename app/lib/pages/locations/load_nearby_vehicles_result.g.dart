// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_nearby_vehicles_result.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LoadNearbyVehiclesResult extends Equatable {
  const LoadNearbyVehiclesResult(this._type);

  factory LoadNearbyVehiclesResult.success() = Success;

  factory LoadNearbyVehiclesResult.noConnection() = NoConnection;

  factory LoadNearbyVehiclesResult.failedToGetUserLocation(
      {@required dynamic locationResult}) = FailedToGetUserLocation;

  final _LoadNearbyVehiclesResult _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Success) success,
      @required R Function(NoConnection) noConnection,
      @required R Function(FailedToGetUserLocation) failedToGetUserLocation}) {
    assert(() {
      if (success == null ||
          noConnection == null ||
          failedToGetUserLocation == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LoadNearbyVehiclesResult.Success:
        return success(this as Success);
      case _LoadNearbyVehiclesResult.NoConnection:
        return noConnection(this as NoConnection);
      case _LoadNearbyVehiclesResult.FailedToGetUserLocation:
        return failedToGetUserLocation(this as FailedToGetUserLocation);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(Success) success,
      @required
          FutureOr<R> Function(NoConnection) noConnection,
      @required
          FutureOr<R> Function(FailedToGetUserLocation)
              failedToGetUserLocation}) {
    assert(() {
      if (success == null ||
          noConnection == null ||
          failedToGetUserLocation == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LoadNearbyVehiclesResult.Success:
        return success(this as Success);
      case _LoadNearbyVehiclesResult.NoConnection:
        return noConnection(this as NoConnection);
      case _LoadNearbyVehiclesResult.FailedToGetUserLocation:
        return failedToGetUserLocation(this as FailedToGetUserLocation);
    }
  }

  R whenOrElse<R>(
      {R Function(Success) success,
      R Function(NoConnection) noConnection,
      R Function(FailedToGetUserLocation) failedToGetUserLocation,
      @required R Function(LoadNearbyVehiclesResult) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LoadNearbyVehiclesResult.Success:
        if (success == null) break;
        return success(this as Success);
      case _LoadNearbyVehiclesResult.NoConnection:
        if (noConnection == null) break;
        return noConnection(this as NoConnection);
      case _LoadNearbyVehiclesResult.FailedToGetUserLocation:
        if (failedToGetUserLocation == null) break;
        return failedToGetUserLocation(this as FailedToGetUserLocation);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Success) success,
      FutureOr<R> Function(NoConnection) noConnection,
      FutureOr<R> Function(FailedToGetUserLocation) failedToGetUserLocation,
      @required FutureOr<R> Function(LoadNearbyVehiclesResult) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LoadNearbyVehiclesResult.Success:
        if (success == null) break;
        return success(this as Success);
      case _LoadNearbyVehiclesResult.NoConnection:
        if (noConnection == null) break;
        return noConnection(this as NoConnection);
      case _LoadNearbyVehiclesResult.FailedToGetUserLocation:
        if (failedToGetUserLocation == null) break;
        return failedToGetUserLocation(this as FailedToGetUserLocation);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Success) success,
      FutureOr<void> Function(NoConnection) noConnection,
      FutureOr<void> Function(FailedToGetUserLocation)
          failedToGetUserLocation}) {
    assert(() {
      if (success == null &&
          noConnection == null &&
          failedToGetUserLocation == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LoadNearbyVehiclesResult.Success:
        if (success == null) break;
        return success(this as Success);
      case _LoadNearbyVehiclesResult.NoConnection:
        if (noConnection == null) break;
        return noConnection(this as NoConnection);
      case _LoadNearbyVehiclesResult.FailedToGetUserLocation:
        if (failedToGetUserLocation == null) break;
        return failedToGetUserLocation(this as FailedToGetUserLocation);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Success extends LoadNearbyVehiclesResult {
  const Success._() : super(_LoadNearbyVehiclesResult.Success);

  factory Success() {
    _instance ??= const Success._();
    return _instance;
  }

  static Success _instance;
}

@immutable
class NoConnection extends LoadNearbyVehiclesResult {
  const NoConnection._() : super(_LoadNearbyVehiclesResult.NoConnection);

  factory NoConnection() {
    _instance ??= const NoConnection._();
    return _instance;
  }

  static NoConnection _instance;
}

@immutable
class FailedToGetUserLocation extends LoadNearbyVehiclesResult {
  const FailedToGetUserLocation({@required this.locationResult})
      : super(_LoadNearbyVehiclesResult.FailedToGetUserLocation);

  final dynamic locationResult;

  @override
  String toString() =>
      'FailedToGetUserLocation(locationResult:${this.locationResult})';
  @override
  List get props => [locationResult];
}
