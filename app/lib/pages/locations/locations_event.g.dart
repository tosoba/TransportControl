// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LocationsEvent extends Equatable {
  const LocationsEvent(this._type);

  factory LocationsEvent.updateLocations({@required List<Location> locations}) =
      UpdateLocations;

  factory LocationsEvent.changeListOrder({@required LocationsListOrder order}) =
      ChangeListOrder;

  final _LocationsEvent _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(UpdateLocations) updateLocations,
      @required R Function(ChangeListOrder) changeListOrder}) {
    assert(() {
      if (updateLocations == null || changeListOrder == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsEvent.UpdateLocations:
        return updateLocations(this as UpdateLocations);
      case _LocationsEvent.ChangeListOrder:
        return changeListOrder(this as ChangeListOrder);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(UpdateLocations) updateLocations,
      @required FutureOr<R> Function(ChangeListOrder) changeListOrder}) {
    assert(() {
      if (updateLocations == null || changeListOrder == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsEvent.UpdateLocations:
        return updateLocations(this as UpdateLocations);
      case _LocationsEvent.ChangeListOrder:
        return changeListOrder(this as ChangeListOrder);
    }
  }

  R whenOrElse<R>(
      {R Function(UpdateLocations) updateLocations,
      R Function(ChangeListOrder) changeListOrder,
      @required R Function(LocationsEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsEvent.UpdateLocations:
        if (updateLocations == null) break;
        return updateLocations(this as UpdateLocations);
      case _LocationsEvent.ChangeListOrder:
        if (changeListOrder == null) break;
        return changeListOrder(this as ChangeListOrder);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(UpdateLocations) updateLocations,
      FutureOr<R> Function(ChangeListOrder) changeListOrder,
      @required FutureOr<R> Function(LocationsEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsEvent.UpdateLocations:
        if (updateLocations == null) break;
        return updateLocations(this as UpdateLocations);
      case _LocationsEvent.ChangeListOrder:
        if (changeListOrder == null) break;
        return changeListOrder(this as ChangeListOrder);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(UpdateLocations) updateLocations,
      FutureOr<void> Function(ChangeListOrder) changeListOrder}) {
    assert(() {
      if (updateLocations == null && changeListOrder == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LocationsEvent.UpdateLocations:
        if (updateLocations == null) break;
        return updateLocations(this as UpdateLocations);
      case _LocationsEvent.ChangeListOrder:
        if (changeListOrder == null) break;
        return changeListOrder(this as ChangeListOrder);
    }
  }

  @override
  List get props => const [];
}

@immutable
class UpdateLocations extends LocationsEvent {
  const UpdateLocations({@required this.locations})
      : super(_LocationsEvent.UpdateLocations);

  final List<Location> locations;

  @override
  String toString() => 'UpdateLocations(locations:${this.locations})';
  @override
  List get props => [locations];
}

@immutable
class ChangeListOrder extends LocationsEvent {
  const ChangeListOrder({@required this.order})
      : super(_LocationsEvent.ChangeListOrder);

  final LocationsListOrder order;

  @override
  String toString() => 'ChangeListOrder(order:${this.order})';
  @override
  List get props => [order];
}
