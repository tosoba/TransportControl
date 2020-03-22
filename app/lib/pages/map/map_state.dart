import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/map/vehicle_animation_stage.dart';

class MapState {
  final Map<String, AnimatedVehicle> trackedVehiclesMap;
  final Set<Line> trackedLines;

  MapState(this.trackedVehiclesMap, this.trackedLines);

  MapState.empty()
      : trackedVehiclesMap = {},
        trackedLines = {};
}
