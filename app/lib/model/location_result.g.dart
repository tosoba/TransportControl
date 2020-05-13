// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_result.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LocationResult extends Equatable {
  const LocationResult(this._type);

  factory LocationResult.success({@required LocationData data}) = Success;

  factory LocationResult.serviceUnavailable() = ServiceUnavailable;

  factory LocationResult.permissionDenied() = PermissionDenied;

  factory LocationResult.permissionDeniedForever() = PermissionDeniedForever;

  factory LocationResult.failure({@required dynamic error}) = Failure;

  final _LocationResult _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Success) success,
      @required R Function(ServiceUnavailable) serviceUnavailable,
      @required R Function(PermissionDenied) permissionDenied,
      @required R Function(PermissionDeniedForever) permissionDeniedForever,
      @required R Function(Failure) failure}) {
    assert(() {
      if (success == null ||
          serviceUnavailable == null ||
          permissionDenied == null ||
          permissionDeniedForever == null ||
          failure == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationResult.Success:
        return success(this as Success);
      case _LocationResult.ServiceUnavailable:
        return serviceUnavailable(this as ServiceUnavailable);
      case _LocationResult.PermissionDenied:
        return permissionDenied(this as PermissionDenied);
      case _LocationResult.PermissionDeniedForever:
        return permissionDeniedForever(this as PermissionDeniedForever);
      case _LocationResult.Failure:
        return failure(this as Failure);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(Success) success,
      @required
          FutureOr<R> Function(ServiceUnavailable) serviceUnavailable,
      @required
          FutureOr<R> Function(PermissionDenied) permissionDenied,
      @required
          FutureOr<R> Function(PermissionDeniedForever) permissionDeniedForever,
      @required
          FutureOr<R> Function(Failure) failure}) {
    assert(() {
      if (success == null ||
          serviceUnavailable == null ||
          permissionDenied == null ||
          permissionDeniedForever == null ||
          failure == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationResult.Success:
        return success(this as Success);
      case _LocationResult.ServiceUnavailable:
        return serviceUnavailable(this as ServiceUnavailable);
      case _LocationResult.PermissionDenied:
        return permissionDenied(this as PermissionDenied);
      case _LocationResult.PermissionDeniedForever:
        return permissionDeniedForever(this as PermissionDeniedForever);
      case _LocationResult.Failure:
        return failure(this as Failure);
    }
  }

  R whenOrElse<R>(
      {R Function(Success) success,
      R Function(ServiceUnavailable) serviceUnavailable,
      R Function(PermissionDenied) permissionDenied,
      R Function(PermissionDeniedForever) permissionDeniedForever,
      R Function(Failure) failure,
      @required R Function(LocationResult) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationResult.Success:
        if (success == null) break;
        return success(this as Success);
      case _LocationResult.ServiceUnavailable:
        if (serviceUnavailable == null) break;
        return serviceUnavailable(this as ServiceUnavailable);
      case _LocationResult.PermissionDenied:
        if (permissionDenied == null) break;
        return permissionDenied(this as PermissionDenied);
      case _LocationResult.PermissionDeniedForever:
        if (permissionDeniedForever == null) break;
        return permissionDeniedForever(this as PermissionDeniedForever);
      case _LocationResult.Failure:
        if (failure == null) break;
        return failure(this as Failure);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Success) success,
      FutureOr<R> Function(ServiceUnavailable) serviceUnavailable,
      FutureOr<R> Function(PermissionDenied) permissionDenied,
      FutureOr<R> Function(PermissionDeniedForever) permissionDeniedForever,
      FutureOr<R> Function(Failure) failure,
      @required FutureOr<R> Function(LocationResult) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationResult.Success:
        if (success == null) break;
        return success(this as Success);
      case _LocationResult.ServiceUnavailable:
        if (serviceUnavailable == null) break;
        return serviceUnavailable(this as ServiceUnavailable);
      case _LocationResult.PermissionDenied:
        if (permissionDenied == null) break;
        return permissionDenied(this as PermissionDenied);
      case _LocationResult.PermissionDeniedForever:
        if (permissionDeniedForever == null) break;
        return permissionDeniedForever(this as PermissionDeniedForever);
      case _LocationResult.Failure:
        if (failure == null) break;
        return failure(this as Failure);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Success) success,
      FutureOr<void> Function(ServiceUnavailable) serviceUnavailable,
      FutureOr<void> Function(PermissionDenied) permissionDenied,
      FutureOr<void> Function(PermissionDeniedForever) permissionDeniedForever,
      FutureOr<void> Function(Failure) failure}) {
    assert(() {
      if (success == null &&
          serviceUnavailable == null &&
          permissionDenied == null &&
          permissionDeniedForever == null &&
          failure == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationResult.Success:
        if (success == null) break;
        return success(this as Success);
      case _LocationResult.ServiceUnavailable:
        if (serviceUnavailable == null) break;
        return serviceUnavailable(this as ServiceUnavailable);
      case _LocationResult.PermissionDenied:
        if (permissionDenied == null) break;
        return permissionDenied(this as PermissionDenied);
      case _LocationResult.PermissionDeniedForever:
        if (permissionDeniedForever == null) break;
        return permissionDeniedForever(this as PermissionDeniedForever);
      case _LocationResult.Failure:
        if (failure == null) break;
        return failure(this as Failure);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Success extends LocationResult {
  const Success({@required this.data}) : super(_LocationResult.Success);

  final LocationData data;

  @override
  String toString() => 'Success(data:${this.data})';
  @override
  List get props => [data];
}

@immutable
class ServiceUnavailable extends LocationResult {
  const ServiceUnavailable._() : super(_LocationResult.ServiceUnavailable);

  factory ServiceUnavailable() {
    _instance ??= const ServiceUnavailable._();
    return _instance;
  }

  static ServiceUnavailable _instance;
}

@immutable
class PermissionDenied extends LocationResult {
  const PermissionDenied._() : super(_LocationResult.PermissionDenied);

  factory PermissionDenied() {
    _instance ??= const PermissionDenied._();
    return _instance;
  }

  static PermissionDenied _instance;
}

@immutable
class PermissionDeniedForever extends LocationResult {
  const PermissionDeniedForever._()
      : super(_LocationResult.PermissionDeniedForever);

  factory PermissionDeniedForever() {
    _instance ??= const PermissionDeniedForever._();
    return _instance;
  }

  static PermissionDeniedForever _instance;
}

@immutable
class Failure extends LocationResult {
  const Failure({@required this.error}) : super(_LocationResult.Failure);

  final dynamic error;

  @override
  String toString() => 'Failure(error:${this.error})';
  @override
  List get props => [error];
}
