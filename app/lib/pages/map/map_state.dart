part of 'package:transport_control/pages/map/map_bloc.dart';

class MapState {
  final Set<Vehicle> trackedVehicles;
  final Set<Line> trackedLines;

  MapState(this.trackedVehicles, this.trackedLines);

  MapState.empty()
      : trackedVehicles = {},
        trackedLines = {};
}
