// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class MapEvent extends Equatable {
  const MapEvent(this._type);

  factory MapEvent.clearMap() = ClearMap;

  factory MapEvent.trackedLinesAdded({@required Set<Line> lines}) =
      TrackedLinesAdded;

  factory MapEvent.vehiclesAdded(VehiclesAddedTemplate vehiclesAddedTemplate) =
      VehiclesAddedTemplateWrapper;

  factory MapEvent.vehiclesAnimated() = VehiclesAnimated;

  factory MapEvent.cameraMoved(
      {@required LatLngBounds bounds, @required double zoom}) = CameraMoved;

  final _MapEvent _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(ClearMap) clearMap,
      @required R Function(TrackedLinesAdded) trackedLinesAdded,
      @required R Function(VehiclesAddedTemplate) vehiclesAdded,
      @required R Function(VehiclesAnimated) vehiclesAnimated,
      @required R Function(CameraMoved) cameraMoved}) {
    assert(() {
      if (clearMap == null ||
          trackedLinesAdded == null ||
          vehiclesAdded == null ||
          vehiclesAnimated == null ||
          cameraMoved == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        return clearMap(this as ClearMap);
      case _MapEvent.TrackedLinesAdded:
        return trackedLinesAdded(this as TrackedLinesAdded);
      case _MapEvent.VehiclesAdded:
        return vehiclesAdded(
            (this as VehiclesAddedTemplateWrapper).vehiclesAddedTemplate);
      case _MapEvent.VehiclesAnimated:
        return vehiclesAnimated(this as VehiclesAnimated);
      case _MapEvent.CameraMoved:
        return cameraMoved(this as CameraMoved);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(ClearMap) clearMap,
      @required FutureOr<R> Function(TrackedLinesAdded) trackedLinesAdded,
      @required FutureOr<R> Function(VehiclesAddedTemplate) vehiclesAdded,
      @required FutureOr<R> Function(VehiclesAnimated) vehiclesAnimated,
      @required FutureOr<R> Function(CameraMoved) cameraMoved}) {
    assert(() {
      if (clearMap == null ||
          trackedLinesAdded == null ||
          vehiclesAdded == null ||
          vehiclesAnimated == null ||
          cameraMoved == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        return clearMap(this as ClearMap);
      case _MapEvent.TrackedLinesAdded:
        return trackedLinesAdded(this as TrackedLinesAdded);
      case _MapEvent.VehiclesAdded:
        return vehiclesAdded(
            (this as VehiclesAddedTemplateWrapper).vehiclesAddedTemplate);
      case _MapEvent.VehiclesAnimated:
        return vehiclesAnimated(this as VehiclesAnimated);
      case _MapEvent.CameraMoved:
        return cameraMoved(this as CameraMoved);
    }
  }

  R whenOrElse<R>(
      {R Function(ClearMap) clearMap,
      R Function(TrackedLinesAdded) trackedLinesAdded,
      R Function(VehiclesAddedTemplate) vehiclesAdded,
      R Function(VehiclesAnimated) vehiclesAnimated,
      R Function(CameraMoved) cameraMoved,
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
      case _MapEvent.TrackedLinesAdded:
        if (trackedLinesAdded == null) break;
        return trackedLinesAdded(this as TrackedLinesAdded);
      case _MapEvent.VehiclesAdded:
        if (vehiclesAdded == null) break;
        return vehiclesAdded(
            (this as VehiclesAddedTemplateWrapper).vehiclesAddedTemplate);
      case _MapEvent.VehiclesAnimated:
        if (vehiclesAnimated == null) break;
        return vehiclesAnimated(this as VehiclesAnimated);
      case _MapEvent.CameraMoved:
        if (cameraMoved == null) break;
        return cameraMoved(this as CameraMoved);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(ClearMap) clearMap,
      FutureOr<R> Function(TrackedLinesAdded) trackedLinesAdded,
      FutureOr<R> Function(VehiclesAddedTemplate) vehiclesAdded,
      FutureOr<R> Function(VehiclesAnimated) vehiclesAnimated,
      FutureOr<R> Function(CameraMoved) cameraMoved,
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
      case _MapEvent.TrackedLinesAdded:
        if (trackedLinesAdded == null) break;
        return trackedLinesAdded(this as TrackedLinesAdded);
      case _MapEvent.VehiclesAdded:
        if (vehiclesAdded == null) break;
        return vehiclesAdded(
            (this as VehiclesAddedTemplateWrapper).vehiclesAddedTemplate);
      case _MapEvent.VehiclesAnimated:
        if (vehiclesAnimated == null) break;
        return vehiclesAnimated(this as VehiclesAnimated);
      case _MapEvent.CameraMoved:
        if (cameraMoved == null) break;
        return cameraMoved(this as CameraMoved);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(ClearMap) clearMap,
      FutureOr<void> Function(TrackedLinesAdded) trackedLinesAdded,
      FutureOr<void> Function(VehiclesAddedTemplate) vehiclesAdded,
      FutureOr<void> Function(VehiclesAnimated) vehiclesAnimated,
      FutureOr<void> Function(CameraMoved) cameraMoved}) {
    assert(() {
      if (clearMap == null &&
          trackedLinesAdded == null &&
          vehiclesAdded == null &&
          vehiclesAnimated == null &&
          cameraMoved == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _MapEvent.ClearMap:
        if (clearMap == null) break;
        return clearMap(this as ClearMap);
      case _MapEvent.TrackedLinesAdded:
        if (trackedLinesAdded == null) break;
        return trackedLinesAdded(this as TrackedLinesAdded);
      case _MapEvent.VehiclesAdded:
        if (vehiclesAdded == null) break;
        return vehiclesAdded(
            (this as VehiclesAddedTemplateWrapper).vehiclesAddedTemplate);
      case _MapEvent.VehiclesAnimated:
        if (vehiclesAnimated == null) break;
        return vehiclesAnimated(this as VehiclesAnimated);
      case _MapEvent.CameraMoved:
        if (cameraMoved == null) break;
        return cameraMoved(this as CameraMoved);
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
class TrackedLinesAdded extends MapEvent {
  const TrackedLinesAdded({@required this.lines})
      : super(_MapEvent.TrackedLinesAdded);

  final Set<Line> lines;

  @override
  String toString() => 'TrackedLinesAdded(lines:${this.lines})';
  @override
  List get props => [lines];
}

@immutable
class VehiclesAddedTemplateWrapper extends MapEvent {
  const VehiclesAddedTemplateWrapper(this.vehiclesAddedTemplate)
      : super(_MapEvent.VehiclesAdded);

  final VehiclesAddedTemplate vehiclesAddedTemplate;

  @override
  String toString() => 'VehiclesAddedTemplateWrapper($vehiclesAddedTemplate)';
  @override
  List get props => [vehiclesAddedTemplate];
}

@immutable
class VehiclesAnimated extends MapEvent {
  const VehiclesAnimated._() : super(_MapEvent.VehiclesAnimated);

  factory VehiclesAnimated() {
    _instance ??= const VehiclesAnimated._();
    return _instance;
  }

  static VehiclesAnimated _instance;
}

@immutable
class CameraMoved extends MapEvent {
  const CameraMoved({@required this.bounds, @required this.zoom})
      : super(_MapEvent.CameraMoved);

  final LatLngBounds bounds;

  final double zoom;

  @override
  String toString() => 'CameraMoved(bounds:${this.bounds},zoom:${this.zoom})';
  @override
  List get props => [bounds, zoom];
}
