// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_selected_vehicle_update.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapSelectedVehicleUpdate extends Equatable {
  const MapSelectedVehicleUpdate(this._type);

  factory MapSelectedVehicleUpdate.noChange() = NoChange;

  factory MapSelectedVehicleUpdate.deselect() = Deselect;

  factory MapSelectedVehicleUpdate.select({@required String number}) = Select;

  final _MapSelectedVehicleUpdate _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(NoChange) noChange,
      @required R Function(Deselect) deselect,
      @required R Function(Select) select}) {
    assert(() {
      if (noChange == null || deselect == null || select == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSelectedVehicleUpdate.NoChange:
        return noChange(this as NoChange);
      case _MapSelectedVehicleUpdate.Deselect:
        return deselect(this as Deselect);
      case _MapSelectedVehicleUpdate.Select:
        return select(this as Select);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(NoChange) noChange,
      @required FutureOr<R> Function(Deselect) deselect,
      @required FutureOr<R> Function(Select) select}) {
    assert(() {
      if (noChange == null || deselect == null || select == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSelectedVehicleUpdate.NoChange:
        return noChange(this as NoChange);
      case _MapSelectedVehicleUpdate.Deselect:
        return deselect(this as Deselect);
      case _MapSelectedVehicleUpdate.Select:
        return select(this as Select);
    }
  }

  R whenOrElse<R>(
      {R Function(NoChange) noChange,
      R Function(Deselect) deselect,
      R Function(Select) select,
      @required R Function(MapSelectedVehicleUpdate) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSelectedVehicleUpdate.NoChange:
        if (noChange == null) break;
        return noChange(this as NoChange);
      case _MapSelectedVehicleUpdate.Deselect:
        if (deselect == null) break;
        return deselect(this as Deselect);
      case _MapSelectedVehicleUpdate.Select:
        if (select == null) break;
        return select(this as Select);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(NoChange) noChange,
      FutureOr<R> Function(Deselect) deselect,
      FutureOr<R> Function(Select) select,
      @required FutureOr<R> Function(MapSelectedVehicleUpdate) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSelectedVehicleUpdate.NoChange:
        if (noChange == null) break;
        return noChange(this as NoChange);
      case _MapSelectedVehicleUpdate.Deselect:
        if (deselect == null) break;
        return deselect(this as Deselect);
      case _MapSelectedVehicleUpdate.Select:
        if (select == null) break;
        return select(this as Select);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(NoChange) noChange,
      FutureOr<void> Function(Deselect) deselect,
      FutureOr<void> Function(Select) select}) {
    assert(() {
      if (noChange == null && deselect == null && select == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapSelectedVehicleUpdate.NoChange:
        if (noChange == null) break;
        return noChange(this as NoChange);
      case _MapSelectedVehicleUpdate.Deselect:
        if (deselect == null) break;
        return deselect(this as Deselect);
      case _MapSelectedVehicleUpdate.Select:
        if (select == null) break;
        return select(this as Select);
    }
  }

  @override
  List get props => const [];
}

@immutable
class NoChange extends MapSelectedVehicleUpdate {
  const NoChange._() : super(_MapSelectedVehicleUpdate.NoChange);

  factory NoChange() {
    _instance ??= const NoChange._();
    return _instance;
  }

  static NoChange _instance;
}

@immutable
class Deselect extends MapSelectedVehicleUpdate {
  const Deselect._() : super(_MapSelectedVehicleUpdate.Deselect);

  factory Deselect() {
    _instance ??= const Deselect._();
    return _instance;
  }

  static Deselect _instance;
}

@immutable
class Select extends MapSelectedVehicleUpdate {
  const Select({@required this.number})
      : super(_MapSelectedVehicleUpdate.Select);

  final String number;

  @override
  String toString() => 'Select(number:${this.number})';
  @override
  List get props => [number];
}
