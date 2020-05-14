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

  factory MapVehicleSource.inBounds(
      {@required LatLngBounds bounds, @required DateTime loadedAt}) = InBounds;

  factory MapVehicleSource.nearby(
      {@required LatLng position,
      @required double radius,
      @required DateTime loadedAt}) = Nearby;

  final _MapVehicleSource _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(OfLine) ofLine,
      @required R Function(InBounds) inBounds,
      @required R Function(Nearby) nearby}) {
    assert(() {
      if (ofLine == null || inBounds == null || nearby == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        return ofLine(this as OfLine);
      case _MapVehicleSource.InBounds:
        return inBounds(this as InBounds);
      case _MapVehicleSource.Nearby:
        return nearby(this as Nearby);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(OfLine) ofLine,
      @required FutureOr<R> Function(InBounds) inBounds,
      @required FutureOr<R> Function(Nearby) nearby}) {
    assert(() {
      if (ofLine == null || inBounds == null || nearby == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        return ofLine(this as OfLine);
      case _MapVehicleSource.InBounds:
        return inBounds(this as InBounds);
      case _MapVehicleSource.Nearby:
        return nearby(this as Nearby);
    }
  }

  R whenOrElse<R>(
      {R Function(OfLine) ofLine,
      R Function(InBounds) inBounds,
      R Function(Nearby) nearby,
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
      case _MapVehicleSource.InBounds:
        if (inBounds == null) break;
        return inBounds(this as InBounds);
      case _MapVehicleSource.Nearby:
        if (nearby == null) break;
        return nearby(this as Nearby);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(OfLine) ofLine,
      FutureOr<R> Function(InBounds) inBounds,
      FutureOr<R> Function(Nearby) nearby,
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
      case _MapVehicleSource.InBounds:
        if (inBounds == null) break;
        return inBounds(this as InBounds);
      case _MapVehicleSource.Nearby:
        if (nearby == null) break;
        return nearby(this as Nearby);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(OfLine) ofLine,
      FutureOr<void> Function(InBounds) inBounds,
      FutureOr<void> Function(Nearby) nearby}) {
    assert(() {
      if (ofLine == null && inBounds == null && nearby == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapVehicleSource.OfLine:
        if (ofLine == null) break;
        return ofLine(this as OfLine);
      case _MapVehicleSource.InBounds:
        if (inBounds == null) break;
        return inBounds(this as InBounds);
      case _MapVehicleSource.Nearby:
        if (nearby == null) break;
        return nearby(this as Nearby);
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
class InBounds extends MapVehicleSource {
  const InBounds({@required this.bounds, @required this.loadedAt})
      : super(_MapVehicleSource.InBounds);

  final LatLngBounds bounds;

  final DateTime loadedAt;

  @override
  String toString() =>
      'InBounds(bounds:${this.bounds},loadedAt:${this.loadedAt})';
  @override
  List get props => [bounds, loadedAt];
}

@immutable
class Nearby extends MapVehicleSource {
  const Nearby(
      {@required this.position, @required this.radius, @required this.loadedAt})
      : super(_MapVehicleSource.Nearby);

  final LatLng position;

  final double radius;

  final DateTime loadedAt;

  @override
  String toString() =>
      'Nearby(position:${this.position},radius:${this.radius},loadedAt:${this.loadedAt})';
  @override
  List get props => [position, radius, loadedAt];
}
