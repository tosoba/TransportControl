part of 'package:transport_control/pages/map/map_bloc.dart';

class _MapEvent
    extends Union3Impl<_ClearMap, _TrackedLinesAdded, _VehiclesAdded> {
  static final Triplet<_ClearMap, _TrackedLinesAdded, _VehiclesAdded> _factory =
      const Triplet<_ClearMap, _TrackedLinesAdded, _VehiclesAdded>();

  _MapEvent._(Union3<_ClearMap, _TrackedLinesAdded, _VehiclesAdded> union)
      : super(union);

  factory _MapEvent.clearMap() => _MapEvent._(_factory.first(_ClearMap()));
  factory _MapEvent.trackedLinesAdded(Set<Line> lines) =>
      _MapEvent._(_factory.second(_TrackedLinesAdded(lines)));
  factory _MapEvent.vehiclesAdded(Set<Vehicle> vehicles) =>
      _MapEvent._(_factory.third(_VehiclesAdded(vehicles)));
}

class _ClearMap {}

class _TrackedLinesAdded {
  final Set<Line> lines;

  _TrackedLinesAdded(this.lines);
}

class _VehiclesAdded {
  final Set<Vehicle> vehicles;

  _VehiclesAdded(this.vehicles);
}
