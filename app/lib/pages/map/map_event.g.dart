// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapEvent extends Equatable {
  const MapEvent(this._type);

  factory MapEvent.clearMap() = ClearMap;

  factory MapEvent.updateVehicles({@required Iterable<Vehicle> vehicles}) =
      UpdateVehicles;

  factory MapEvent.addVehiclesOfLines(
      {@required Iterable<Vehicle> vehicles,
      @required Set<Line> lines}) = AddVehiclesOfLines;

  factory MapEvent.addVehiclesInLocation(
      {@required Iterable<Vehicle> vehicles,
      @required Location location}) = AddVehiclesInLocation;

  factory MapEvent.addVehiclesNearbyUserLocation(
      {@required Iterable<Vehicle> vehicles,
      @required LatLng position,
      @required double radius}) = AddVehiclesNearbyUserLocation;

  factory MapEvent.addVehiclesNearbyPlace(
      {@required Iterable<Vehicle> vehicles,
      @required LatLng position,
      @required String title,
      @required double radius}) = AddVehiclesNearbyPlace;

  factory MapEvent.animateVehicles() = AnimateVehicles;

  factory MapEvent.cameraMoved(
      {@required LatLngBounds bounds,
      @required double zoom,
      @required bool byUser}) = CameraMoved;

  factory MapEvent.trackedLinesRemoved({@required Set<Line> lines}) =
      TrackedLinesRemoved;

  factory MapEvent.selectVehicle({@required String number}) = SelectVehicle;

  factory MapEvent.deselectVehicle() = DeselectVehicle;

  factory MapEvent.removeSource({@required dynamic source}) = RemoveSource;

  final _MapEvent _type;

//ignore: missing_return
  R when<R>(
      {@required
          R Function(ClearMap) clearMap,
      @required
          R Function(UpdateVehicles) updateVehicles,
      @required
          R Function(AddVehiclesOfLines) addVehiclesOfLines,
      @required
          R Function(AddVehiclesInLocation) addVehiclesInLocation,
      @required
          R Function(AddVehiclesNearbyUserLocation)
              addVehiclesNearbyUserLocation,
      @required
          R Function(AddVehiclesNearbyPlace) addVehiclesNearbyPlace,
      @required
          R Function(AnimateVehicles) animateVehicles,
      @required
          R Function(CameraMoved) cameraMoved,
      @required
          R Function(TrackedLinesRemoved) trackedLinesRemoved,
      @required
          R Function(SelectVehicle) selectVehicle,
      @required
          R Function(DeselectVehicle) deselectVehicle,
      @required
          R Function(RemoveSource) removeSource}) {
    assert(() {
      if (clearMap == null ||
          updateVehicles == null ||
          addVehiclesOfLines == null ||
          addVehiclesInLocation == null ||
          addVehiclesNearbyUserLocation == null ||
          addVehiclesNearbyPlace == null ||
          animateVehicles == null ||
          cameraMoved == null ||
          trackedLinesRemoved == null ||
          selectVehicle == null ||
          deselectVehicle == null ||
          removeSource == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        return clearMap(this as ClearMap);
      case _MapEvent.UpdateVehicles:
        return updateVehicles(this as UpdateVehicles);
      case _MapEvent.AddVehiclesOfLines:
        return addVehiclesOfLines(this as AddVehiclesOfLines);
      case _MapEvent.AddVehiclesInLocation:
        return addVehiclesInLocation(this as AddVehiclesInLocation);
      case _MapEvent.AddVehiclesNearbyUserLocation:
        return addVehiclesNearbyUserLocation(
            this as AddVehiclesNearbyUserLocation);
      case _MapEvent.AddVehiclesNearbyPlace:
        return addVehiclesNearbyPlace(this as AddVehiclesNearbyPlace);
      case _MapEvent.AnimateVehicles:
        return animateVehicles(this as AnimateVehicles);
      case _MapEvent.CameraMoved:
        return cameraMoved(this as CameraMoved);
      case _MapEvent.TrackedLinesRemoved:
        return trackedLinesRemoved(this as TrackedLinesRemoved);
      case _MapEvent.SelectVehicle:
        return selectVehicle(this as SelectVehicle);
      case _MapEvent.DeselectVehicle:
        return deselectVehicle(this as DeselectVehicle);
      case _MapEvent.RemoveSource:
        return removeSource(this as RemoveSource);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(ClearMap) clearMap,
      @required
          FutureOr<R> Function(UpdateVehicles) updateVehicles,
      @required
          FutureOr<R> Function(AddVehiclesOfLines) addVehiclesOfLines,
      @required
          FutureOr<R> Function(AddVehiclesInLocation) addVehiclesInLocation,
      @required
          FutureOr<R> Function(AddVehiclesNearbyUserLocation)
              addVehiclesNearbyUserLocation,
      @required
          FutureOr<R> Function(AddVehiclesNearbyPlace) addVehiclesNearbyPlace,
      @required
          FutureOr<R> Function(AnimateVehicles) animateVehicles,
      @required
          FutureOr<R> Function(CameraMoved) cameraMoved,
      @required
          FutureOr<R> Function(TrackedLinesRemoved) trackedLinesRemoved,
      @required
          FutureOr<R> Function(SelectVehicle) selectVehicle,
      @required
          FutureOr<R> Function(DeselectVehicle) deselectVehicle,
      @required
          FutureOr<R> Function(RemoveSource) removeSource}) {
    assert(() {
      if (clearMap == null ||
          updateVehicles == null ||
          addVehiclesOfLines == null ||
          addVehiclesInLocation == null ||
          addVehiclesNearbyUserLocation == null ||
          addVehiclesNearbyPlace == null ||
          animateVehicles == null ||
          cameraMoved == null ||
          trackedLinesRemoved == null ||
          selectVehicle == null ||
          deselectVehicle == null ||
          removeSource == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        return clearMap(this as ClearMap);
      case _MapEvent.UpdateVehicles:
        return updateVehicles(this as UpdateVehicles);
      case _MapEvent.AddVehiclesOfLines:
        return addVehiclesOfLines(this as AddVehiclesOfLines);
      case _MapEvent.AddVehiclesInLocation:
        return addVehiclesInLocation(this as AddVehiclesInLocation);
      case _MapEvent.AddVehiclesNearbyUserLocation:
        return addVehiclesNearbyUserLocation(
            this as AddVehiclesNearbyUserLocation);
      case _MapEvent.AddVehiclesNearbyPlace:
        return addVehiclesNearbyPlace(this as AddVehiclesNearbyPlace);
      case _MapEvent.AnimateVehicles:
        return animateVehicles(this as AnimateVehicles);
      case _MapEvent.CameraMoved:
        return cameraMoved(this as CameraMoved);
      case _MapEvent.TrackedLinesRemoved:
        return trackedLinesRemoved(this as TrackedLinesRemoved);
      case _MapEvent.SelectVehicle:
        return selectVehicle(this as SelectVehicle);
      case _MapEvent.DeselectVehicle:
        return deselectVehicle(this as DeselectVehicle);
      case _MapEvent.RemoveSource:
        return removeSource(this as RemoveSource);
    }
  }

  R whenOrElse<R>(
      {R Function(ClearMap) clearMap,
      R Function(UpdateVehicles) updateVehicles,
      R Function(AddVehiclesOfLines) addVehiclesOfLines,
      R Function(AddVehiclesInLocation) addVehiclesInLocation,
      R Function(AddVehiclesNearbyUserLocation) addVehiclesNearbyUserLocation,
      R Function(AddVehiclesNearbyPlace) addVehiclesNearbyPlace,
      R Function(AnimateVehicles) animateVehicles,
      R Function(CameraMoved) cameraMoved,
      R Function(TrackedLinesRemoved) trackedLinesRemoved,
      R Function(SelectVehicle) selectVehicle,
      R Function(DeselectVehicle) deselectVehicle,
      R Function(RemoveSource) removeSource,
      @required R Function(MapEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        if (clearMap == null) break;
        return clearMap(this as ClearMap);
      case _MapEvent.UpdateVehicles:
        if (updateVehicles == null) break;
        return updateVehicles(this as UpdateVehicles);
      case _MapEvent.AddVehiclesOfLines:
        if (addVehiclesOfLines == null) break;
        return addVehiclesOfLines(this as AddVehiclesOfLines);
      case _MapEvent.AddVehiclesInLocation:
        if (addVehiclesInLocation == null) break;
        return addVehiclesInLocation(this as AddVehiclesInLocation);
      case _MapEvent.AddVehiclesNearbyUserLocation:
        if (addVehiclesNearbyUserLocation == null) break;
        return addVehiclesNearbyUserLocation(
            this as AddVehiclesNearbyUserLocation);
      case _MapEvent.AddVehiclesNearbyPlace:
        if (addVehiclesNearbyPlace == null) break;
        return addVehiclesNearbyPlace(this as AddVehiclesNearbyPlace);
      case _MapEvent.AnimateVehicles:
        if (animateVehicles == null) break;
        return animateVehicles(this as AnimateVehicles);
      case _MapEvent.CameraMoved:
        if (cameraMoved == null) break;
        return cameraMoved(this as CameraMoved);
      case _MapEvent.TrackedLinesRemoved:
        if (trackedLinesRemoved == null) break;
        return trackedLinesRemoved(this as TrackedLinesRemoved);
      case _MapEvent.SelectVehicle:
        if (selectVehicle == null) break;
        return selectVehicle(this as SelectVehicle);
      case _MapEvent.DeselectVehicle:
        if (deselectVehicle == null) break;
        return deselectVehicle(this as DeselectVehicle);
      case _MapEvent.RemoveSource:
        if (removeSource == null) break;
        return removeSource(this as RemoveSource);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(ClearMap) clearMap,
      FutureOr<R> Function(UpdateVehicles) updateVehicles,
      FutureOr<R> Function(AddVehiclesOfLines) addVehiclesOfLines,
      FutureOr<R> Function(AddVehiclesInLocation) addVehiclesInLocation,
      FutureOr<R> Function(AddVehiclesNearbyUserLocation)
          addVehiclesNearbyUserLocation,
      FutureOr<R> Function(AddVehiclesNearbyPlace) addVehiclesNearbyPlace,
      FutureOr<R> Function(AnimateVehicles) animateVehicles,
      FutureOr<R> Function(CameraMoved) cameraMoved,
      FutureOr<R> Function(TrackedLinesRemoved) trackedLinesRemoved,
      FutureOr<R> Function(SelectVehicle) selectVehicle,
      FutureOr<R> Function(DeselectVehicle) deselectVehicle,
      FutureOr<R> Function(RemoveSource) removeSource,
      @required FutureOr<R> Function(MapEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        if (clearMap == null) break;
        return clearMap(this as ClearMap);
      case _MapEvent.UpdateVehicles:
        if (updateVehicles == null) break;
        return updateVehicles(this as UpdateVehicles);
      case _MapEvent.AddVehiclesOfLines:
        if (addVehiclesOfLines == null) break;
        return addVehiclesOfLines(this as AddVehiclesOfLines);
      case _MapEvent.AddVehiclesInLocation:
        if (addVehiclesInLocation == null) break;
        return addVehiclesInLocation(this as AddVehiclesInLocation);
      case _MapEvent.AddVehiclesNearbyUserLocation:
        if (addVehiclesNearbyUserLocation == null) break;
        return addVehiclesNearbyUserLocation(
            this as AddVehiclesNearbyUserLocation);
      case _MapEvent.AddVehiclesNearbyPlace:
        if (addVehiclesNearbyPlace == null) break;
        return addVehiclesNearbyPlace(this as AddVehiclesNearbyPlace);
      case _MapEvent.AnimateVehicles:
        if (animateVehicles == null) break;
        return animateVehicles(this as AnimateVehicles);
      case _MapEvent.CameraMoved:
        if (cameraMoved == null) break;
        return cameraMoved(this as CameraMoved);
      case _MapEvent.TrackedLinesRemoved:
        if (trackedLinesRemoved == null) break;
        return trackedLinesRemoved(this as TrackedLinesRemoved);
      case _MapEvent.SelectVehicle:
        if (selectVehicle == null) break;
        return selectVehicle(this as SelectVehicle);
      case _MapEvent.DeselectVehicle:
        if (deselectVehicle == null) break;
        return deselectVehicle(this as DeselectVehicle);
      case _MapEvent.RemoveSource:
        if (removeSource == null) break;
        return removeSource(this as RemoveSource);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(ClearMap) clearMap,
      FutureOr<void> Function(UpdateVehicles) updateVehicles,
      FutureOr<void> Function(AddVehiclesOfLines) addVehiclesOfLines,
      FutureOr<void> Function(AddVehiclesInLocation) addVehiclesInLocation,
      FutureOr<void> Function(AddVehiclesNearbyUserLocation)
          addVehiclesNearbyUserLocation,
      FutureOr<void> Function(AddVehiclesNearbyPlace) addVehiclesNearbyPlace,
      FutureOr<void> Function(AnimateVehicles) animateVehicles,
      FutureOr<void> Function(CameraMoved) cameraMoved,
      FutureOr<void> Function(TrackedLinesRemoved) trackedLinesRemoved,
      FutureOr<void> Function(SelectVehicle) selectVehicle,
      FutureOr<void> Function(DeselectVehicle) deselectVehicle,
      FutureOr<void> Function(RemoveSource) removeSource}) {
    assert(() {
      if (clearMap == null &&
          updateVehicles == null &&
          addVehiclesOfLines == null &&
          addVehiclesInLocation == null &&
          addVehiclesNearbyUserLocation == null &&
          addVehiclesNearbyPlace == null &&
          animateVehicles == null &&
          cameraMoved == null &&
          trackedLinesRemoved == null &&
          selectVehicle == null &&
          deselectVehicle == null &&
          removeSource == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        if (clearMap == null) break;
        return clearMap(this as ClearMap);
      case _MapEvent.UpdateVehicles:
        if (updateVehicles == null) break;
        return updateVehicles(this as UpdateVehicles);
      case _MapEvent.AddVehiclesOfLines:
        if (addVehiclesOfLines == null) break;
        return addVehiclesOfLines(this as AddVehiclesOfLines);
      case _MapEvent.AddVehiclesInLocation:
        if (addVehiclesInLocation == null) break;
        return addVehiclesInLocation(this as AddVehiclesInLocation);
      case _MapEvent.AddVehiclesNearbyUserLocation:
        if (addVehiclesNearbyUserLocation == null) break;
        return addVehiclesNearbyUserLocation(
            this as AddVehiclesNearbyUserLocation);
      case _MapEvent.AddVehiclesNearbyPlace:
        if (addVehiclesNearbyPlace == null) break;
        return addVehiclesNearbyPlace(this as AddVehiclesNearbyPlace);
      case _MapEvent.AnimateVehicles:
        if (animateVehicles == null) break;
        return animateVehicles(this as AnimateVehicles);
      case _MapEvent.CameraMoved:
        if (cameraMoved == null) break;
        return cameraMoved(this as CameraMoved);
      case _MapEvent.TrackedLinesRemoved:
        if (trackedLinesRemoved == null) break;
        return trackedLinesRemoved(this as TrackedLinesRemoved);
      case _MapEvent.SelectVehicle:
        if (selectVehicle == null) break;
        return selectVehicle(this as SelectVehicle);
      case _MapEvent.DeselectVehicle:
        if (deselectVehicle == null) break;
        return deselectVehicle(this as DeselectVehicle);
      case _MapEvent.RemoveSource:
        if (removeSource == null) break;
        return removeSource(this as RemoveSource);
    }
  }

  @override
  List get props => const [];
}

@immutable
class ClearMap extends MapEvent {
  const ClearMap._() : super(_MapEvent.ClearMap);

  factory ClearMap() {
    _instance ??= const ClearMap._();
    return _instance;
  }

  static ClearMap _instance;
}

@immutable
class UpdateVehicles extends MapEvent {
  const UpdateVehicles({@required this.vehicles})
      : super(_MapEvent.UpdateVehicles);

  final Iterable<Vehicle> vehicles;

  @override
  String toString() => 'UpdateVehicles(vehicles:${this.vehicles})';
  @override
  List get props => [vehicles];
}

@immutable
class AddVehiclesOfLines extends MapEvent {
  const AddVehiclesOfLines({@required this.vehicles, @required this.lines})
      : super(_MapEvent.AddVehiclesOfLines);

  final Iterable<Vehicle> vehicles;

  final Set<Line> lines;

  @override
  String toString() =>
      'AddVehiclesOfLines(vehicles:${this.vehicles},lines:${this.lines})';
  @override
  List get props => [vehicles, lines];
}

@immutable
class AddVehiclesInLocation extends MapEvent {
  const AddVehiclesInLocation(
      {@required this.vehicles, @required this.location})
      : super(_MapEvent.AddVehiclesInLocation);

  final Iterable<Vehicle> vehicles;

  final Location location;

  @override
  String toString() =>
      'AddVehiclesInLocation(vehicles:${this.vehicles},location:${this.location})';
  @override
  List get props => [vehicles, location];
}

@immutable
class AddVehiclesNearbyUserLocation extends MapEvent {
  const AddVehiclesNearbyUserLocation(
      {@required this.vehicles, @required this.position, @required this.radius})
      : super(_MapEvent.AddVehiclesNearbyUserLocation);

  final Iterable<Vehicle> vehicles;

  final LatLng position;

  final double radius;

  @override
  String toString() =>
      'AddVehiclesNearbyUserLocation(vehicles:${this.vehicles},position:${this.position},radius:${this.radius})';
  @override
  List get props => [vehicles, position, radius];
}

@immutable
class AddVehiclesNearbyPlace extends MapEvent {
  const AddVehiclesNearbyPlace(
      {@required this.vehicles,
      @required this.position,
      @required this.title,
      @required this.radius})
      : super(_MapEvent.AddVehiclesNearbyPlace);

  final Iterable<Vehicle> vehicles;

  final LatLng position;

  final String title;

  final double radius;

  @override
  String toString() =>
      'AddVehiclesNearbyPlace(vehicles:${this.vehicles},position:${this.position},title:${this.title},radius:${this.radius})';
  @override
  List get props => [vehicles, position, title, radius];
}

@immutable
class AnimateVehicles extends MapEvent {
  const AnimateVehicles._() : super(_MapEvent.AnimateVehicles);

  factory AnimateVehicles() {
    _instance ??= const AnimateVehicles._();
    return _instance;
  }

  static AnimateVehicles _instance;
}

@immutable
class CameraMoved extends MapEvent {
  const CameraMoved(
      {@required this.bounds, @required this.zoom, @required this.byUser})
      : super(_MapEvent.CameraMoved);

  final LatLngBounds bounds;

  final double zoom;

  final bool byUser;

  @override
  String toString() =>
      'CameraMoved(bounds:${this.bounds},zoom:${this.zoom},byUser:${this.byUser})';
  @override
  List get props => [bounds, zoom, byUser];
}

@immutable
class TrackedLinesRemoved extends MapEvent {
  const TrackedLinesRemoved({@required this.lines})
      : super(_MapEvent.TrackedLinesRemoved);

  final Set<Line> lines;

  @override
  String toString() => 'TrackedLinesRemoved(lines:${this.lines})';
  @override
  List get props => [lines];
}

@immutable
class SelectVehicle extends MapEvent {
  const SelectVehicle({@required this.number}) : super(_MapEvent.SelectVehicle);

  final String number;

  @override
  String toString() => 'SelectVehicle(number:${this.number})';
  @override
  List get props => [number];
}

@immutable
class DeselectVehicle extends MapEvent {
  const DeselectVehicle._() : super(_MapEvent.DeselectVehicle);

  factory DeselectVehicle() {
    _instance ??= const DeselectVehicle._();
    return _instance;
  }

  static DeselectVehicle _instance;
}

@immutable
class RemoveSource extends MapEvent {
  const RemoveSource({@required this.source}) : super(_MapEvent.RemoveSource);

  final dynamic source;

  @override
  String toString() => 'RemoveSource(source:${this.source})';
  @override
  List get props => [source];
}
