// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_location_page_mode.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapLocationPageMode extends Equatable {
  const MapLocationPageMode(this._type);

  factory MapLocationPageMode.add() = Add;

  factory MapLocationPageMode.existing({@required Location location}) =
      Existing;

  final _MapLocationPageMode _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Add) add,
      @required R Function(Existing) existing}) {
    assert(() {
      if (add == null || existing == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        return add(this as Add);
      case _MapLocationPageMode.Existing:
        return existing(this as Existing);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(Add) add,
      @required FutureOr<R> Function(Existing) existing}) {
    assert(() {
      if (add == null || existing == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        return add(this as Add);
      case _MapLocationPageMode.Existing:
        return existing(this as Existing);
    }
  }

  R whenOrElse<R>(
      {R Function(Add) add,
      R Function(Existing) existing,
      @required R Function(MapLocationPageMode) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        if (add == null) break;
        return add(this as Add);
      case _MapLocationPageMode.Existing:
        if (existing == null) break;
        return existing(this as Existing);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Add) add,
      FutureOr<R> Function(Existing) existing,
      @required FutureOr<R> Function(MapLocationPageMode) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        if (add == null) break;
        return add(this as Add);
      case _MapLocationPageMode.Existing:
        if (existing == null) break;
        return existing(this as Existing);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Add) add,
      FutureOr<void> Function(Existing) existing}) {
    assert(() {
      if (add == null && existing == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapLocationPageMode.Add:
        if (add == null) break;
        return add(this as Add);
      case _MapLocationPageMode.Existing:
        if (existing == null) break;
        return existing(this as Existing);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Add extends MapLocationPageMode {
  const Add._() : super(_MapLocationPageMode.Add);

  factory Add() {
    _instance ??= const Add._();
    return _instance;
  }

  static Add _instance;
}

@immutable
class Existing extends MapLocationPageMode {
  const Existing({@required this.location})
      : super(_MapLocationPageMode.Existing);

  final Location location;

  @override
  String toString() => 'Existing(location:${this.location})';
  @override
  List get props => [location];
}
