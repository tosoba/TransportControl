// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_source.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class VehicleSource extends Equatable {
  const VehicleSource(this._type);

  factory VehicleSource.allOfLine({@required Line line}) = AllOfLine;

  factory VehicleSource.allInBounds({@required LatLngBounds bounds}) =
      AllInBounds;

  final _VehicleSource _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(AllOfLine) allOfLine,
      @required R Function(AllInBounds) allInBounds}) {
    assert(() {
      if (allOfLine == null || allInBounds == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _VehicleSource.AllOfLine:
        return allOfLine(this as AllOfLine);
      case _VehicleSource.AllInBounds:
        return allInBounds(this as AllInBounds);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(AllOfLine) allOfLine,
      @required FutureOr<R> Function(AllInBounds) allInBounds}) {
    assert(() {
      if (allOfLine == null || allInBounds == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _VehicleSource.AllOfLine:
        return allOfLine(this as AllOfLine);
      case _VehicleSource.AllInBounds:
        return allInBounds(this as AllInBounds);
    }
  }

  R whenOrElse<R>(
      {R Function(AllOfLine) allOfLine,
      R Function(AllInBounds) allInBounds,
      @required R Function(VehicleSource) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _VehicleSource.AllOfLine:
        if (allOfLine == null) break;
        return allOfLine(this as AllOfLine);
      case _VehicleSource.AllInBounds:
        if (allInBounds == null) break;
        return allInBounds(this as AllInBounds);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(AllOfLine) allOfLine,
      FutureOr<R> Function(AllInBounds) allInBounds,
      @required FutureOr<R> Function(VehicleSource) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _VehicleSource.AllOfLine:
        if (allOfLine == null) break;
        return allOfLine(this as AllOfLine);
      case _VehicleSource.AllInBounds:
        if (allInBounds == null) break;
        return allInBounds(this as AllInBounds);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(AllOfLine) allOfLine,
      FutureOr<void> Function(AllInBounds) allInBounds}) {
    assert(() {
      if (allOfLine == null && allInBounds == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _VehicleSource.AllOfLine:
        if (allOfLine == null) break;
        return allOfLine(this as AllOfLine);
      case _VehicleSource.AllInBounds:
        if (allInBounds == null) break;
        return allInBounds(this as AllInBounds);
    }
  }

  @override
  List get props => const [];
}

@immutable
class AllOfLine extends VehicleSource {
  const AllOfLine({@required this.line}) : super(_VehicleSource.AllOfLine);

  final Line line;

  @override
  String toString() => 'AllOfLine(line:${this.line})';
  @override
  List get props => [line];
}

@immutable
class AllInBounds extends VehicleSource {
  const AllInBounds({@required this.bounds})
      : super(_VehicleSource.AllInBounds);

  final LatLngBounds bounds;

  @override
  String toString() => 'AllInBounds(bounds:${this.bounds})';
  @override
  List get props => [bounds];
}
