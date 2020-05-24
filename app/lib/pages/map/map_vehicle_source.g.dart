// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_vehicle_source.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapVehicleSource extends Equatable {
  const MapVehicleSource(this._type);

  factory MapVehicleSource.ofLine(
      {@required Line line, @required DateTime loadedAt}) = OfLine;

  factory MapVehicleSource.nearbyLocation(
      {@required Location location,
      @required DateTime loadedAt}) = NearbyLocation;

  factory MapVehicleSource.nearbyPosition(
      {@required LatLng position,
      @required double radius,
      @required DateTime loadedAt}) = NearbyPosition;

  final _MapVehicleSource _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(OfLine) ofLine,
      @required R Function(NearbyLocation) nearbyLocation,
      @required R Function(NearbyPosition) nearbyPosition}) {
    assert(() {
      if (ofLine == null || nearbyLocation == null || nearbyPosition == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        return ofLine(this as OfLine);
      case _MapVehicleSource.NearbyLocation:
        return nearbyLocation(this as NearbyLocation);
      case _MapVehicleSource.NearbyPosition:
        return nearbyPosition(this as NearbyPosition);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(OfLine) ofLine,
      @required FutureOr<R> Function(NearbyLocation) nearbyLocation,
      @required FutureOr<R> Function(NearbyPosition) nearbyPosition}) {
    assert(() {
      if (ofLine == null || nearbyLocation == null || nearbyPosition == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        return ofLine(this as OfLine);
      case _MapVehicleSource.NearbyLocation:
        return nearbyLocation(this as NearbyLocation);
      case _MapVehicleSource.NearbyPosition:
        return nearbyPosition(this as NearbyPosition);
    }
  }

  R whenOrElse<R>(
      {R Function(OfLine) ofLine,
      R Function(NearbyLocation) nearbyLocation,
      R Function(NearbyPosition) nearbyPosition,
      @required R Function(MapVehicleSource) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        if (ofLine == null) break;
        return ofLine(this as OfLine);
      case _MapVehicleSource.NearbyLocation:
        if (nearbyLocation == null) break;
        return nearbyLocation(this as NearbyLocation);
      case _MapVehicleSource.NearbyPosition:
        if (nearbyPosition == null) break;
        return nearbyPosition(this as NearbyPosition);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(OfLine) ofLine,
      FutureOr<R> Function(NearbyLocation) nearbyLocation,
      FutureOr<R> Function(NearbyPosition) nearbyPosition,
      @required FutureOr<R> Function(MapVehicleSource) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        if (ofLine == null) break;
        return ofLine(this as OfLine);
      case _MapVehicleSource.NearbyLocation:
        if (nearbyLocation == null) break;
        return nearbyLocation(this as NearbyLocation);
      case _MapVehicleSource.NearbyPosition:
        if (nearbyPosition == null) break;
        return nearbyPosition(this as NearbyPosition);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(OfLine) ofLine,
      FutureOr<void> Function(NearbyLocation) nearbyLocation,
      FutureOr<void> Function(NearbyPosition) nearbyPosition}) {
    assert(() {
      if (ofLine == null && nearbyLocation == null && nearbyPosition == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        if (ofLine == null) break;
        return ofLine(this as OfLine);
      case _MapVehicleSource.NearbyLocation:
        if (nearbyLocation == null) break;
        return nearbyLocation(this as NearbyLocation);
      case _MapVehicleSource.NearbyPosition:
        if (nearbyPosition == null) break;
        return nearbyPosition(this as NearbyPosition);
    }
  }

  @override
  List get props => const [];
}

@immutable
class OfLine extends MapVehicleSource {
  const OfLine({@required this.line, @required this.loadedAt})
      : super(_MapVehicleSource.OfLine);

  final Line line;

  final DateTime loadedAt;

  @override
  String toString() => 'OfLine(line:${this.line},loadedAt:${this.loadedAt})';
  @override
  List get props => [line, loadedAt];
}

@immutable
class NearbyLocation extends MapVehicleSource {
  const NearbyLocation({@required this.location, @required this.loadedAt})
      : super(_MapVehicleSource.NearbyLocation);

  final Location location;

  final DateTime loadedAt;

  @override
  String toString() =>
      'NearbyLocation(location:${this.location},loadedAt:${this.loadedAt})';
  @override
  List get props => [location, loadedAt];
}

@immutable
class NearbyPosition extends MapVehicleSource {
  const NearbyPosition(
      {@required this.position, @required this.radius, @required this.loadedAt})
      : super(_MapVehicleSource.NearbyPosition);

  final LatLng position;

  final double radius;

  final DateTime loadedAt;

  @override
  String toString() =>
      'NearbyPosition(position:${this.position},radius:${this.radius},loadedAt:${this.loadedAt})';
  @override
  List get props => [position, radius, loadedAt];
}
