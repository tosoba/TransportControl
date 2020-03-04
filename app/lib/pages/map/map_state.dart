part of 'package:transport_control/pages/map/map_bloc.dart';

class MapState {
  final List<Vehicle> trackedVehicles;
  final List<Line> trackedLines;

  MapState(this.trackedVehicles, this.trackedLines);

  MapState.empty()
      : trackedVehicles = [],
        trackedLines = [];
}