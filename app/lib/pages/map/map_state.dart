part of 'package:transport_control/pages/map/map_bloc.dart';

class MapState {
  final Map<String, AnimatedVehicle> trackedVehiclesMap;
  final Set<Line> trackedLines;

  MapState(this.trackedVehiclesMap, this.trackedLines);

  MapState.empty()
      : trackedVehiclesMap = {},
        trackedLines = {};
}
