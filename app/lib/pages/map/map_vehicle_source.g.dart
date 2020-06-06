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

  factory MapVehicleSource.nearbyUserLocation(
      {@required LatLng position,
      @required double radius,
      @required DateTime loadedAt}) = NearbyUserLocation;

  factory MapVehicleSource.nearbyPlace(
      {@required LatLng position,
      @required String title,
      @required double radius,
      @required DateTime loadedAt}) = NearbyPlace;

  final _MapVehicleSource _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(OfLine) ofLine,
      @required R Function(NearbyLocation) nearbyLocation,
      @required R Function(NearbyUserLocation) nearbyUserLocation,
      @required R Function(NearbyPlace) nearbyPlace}) {
    assert(() {
      if (ofLine == null ||
          nearbyLocation == null ||
          nearbyUserLocation == null ||
          nearbyPlace == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        return ofLine(this as OfLine);
      case _MapVehicleSource.NearbyLocation:
        return nearbyLocation(this as NearbyLocation);
      case _MapVehicleSource.NearbyUserLocation:
        return nearbyUserLocation(this as NearbyUserLocation);
      case _MapVehicleSource.NearbyPlace:
        return nearbyPlace(this as NearbyPlace);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(OfLine) ofLine,
      @required FutureOr<R> Function(NearbyLocation) nearbyLocation,
      @required FutureOr<R> Function(NearbyUserLocation) nearbyUserLocation,
      @required FutureOr<R> Function(NearbyPlace) nearbyPlace}) {
    assert(() {
      if (ofLine == null ||
          nearbyLocation == null ||
          nearbyUserLocation == null ||
          nearbyPlace == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        return ofLine(this as OfLine);
      case _MapVehicleSource.NearbyLocation:
        return nearbyLocation(this as NearbyLocation);
      case _MapVehicleSource.NearbyUserLocation:
        return nearbyUserLocation(this as NearbyUserLocation);
      case _MapVehicleSource.NearbyPlace:
        return nearbyPlace(this as NearbyPlace);
    }
  }

  R whenOrElse<R>(
      {R Function(OfLine) ofLine,
      R Function(NearbyLocation) nearbyLocation,
      R Function(NearbyUserLocation) nearbyUserLocation,
      R Function(NearbyPlace) nearbyPlace,
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
      case _MapVehicleSource.NearbyUserLocation:
        if (nearbyUserLocation == null) break;
        return nearbyUserLocation(this as NearbyUserLocation);
      case _MapVehicleSource.NearbyPlace:
        if (nearbyPlace == null) break;
        return nearbyPlace(this as NearbyPlace);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(OfLine) ofLine,
      FutureOr<R> Function(NearbyLocation) nearbyLocation,
      FutureOr<R> Function(NearbyUserLocation) nearbyUserLocation,
      FutureOr<R> Function(NearbyPlace) nearbyPlace,
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
      case _MapVehicleSource.NearbyUserLocation:
        if (nearbyUserLocation == null) break;
        return nearbyUserLocation(this as NearbyUserLocation);
      case _MapVehicleSource.NearbyPlace:
        if (nearbyPlace == null) break;
        return nearbyPlace(this as NearbyPlace);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(OfLine) ofLine,
      FutureOr<void> Function(NearbyLocation) nearbyLocation,
      FutureOr<void> Function(NearbyUserLocation) nearbyUserLocation,
      FutureOr<void> Function(NearbyPlace) nearbyPlace}) {
    assert(() {
      if (ofLine == null &&
          nearbyLocation == null &&
          nearbyUserLocation == null &&
          nearbyPlace == null) {
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
      case _MapVehicleSource.NearbyUserLocation:
        if (nearbyUserLocation == null) break;
        return nearbyUserLocation(this as NearbyUserLocation);
      case _MapVehicleSource.NearbyPlace:
        if (nearbyPlace == null) break;
        return nearbyPlace(this as NearbyPlace);
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
class NearbyUserLocation extends MapVehicleSource {
  const NearbyUserLocation(
      {@required this.position, @required this.radius, @required this.loadedAt})
      : super(_MapVehicleSource.NearbyUserLocation);

  final LatLng position;

  final double radius;

  final DateTime loadedAt;

  @override
  String toString() =>
      'NearbyUserLocation(position:${this.position},radius:${this.radius},loadedAt:${this.loadedAt})';
  @override
  List get props => [position, radius, loadedAt];
}

@immutable
class NearbyPlace extends MapVehicleSource {
  const NearbyPlace(
      {@required this.position,
      @required this.title,
      @required this.radius,
      @required this.loadedAt})
      : super(_MapVehicleSource.NearbyPlace);

  final LatLng position;

  final String title;

  final double radius;

  final DateTime loadedAt;

  @override
  String toString() =>
      'NearbyPlace(position:${this.position},title:${this.title},radius:${this.radius},loadedAt:${this.loadedAt})';
  @override
  List get props => [position, title, radius, loadedAt];
}
