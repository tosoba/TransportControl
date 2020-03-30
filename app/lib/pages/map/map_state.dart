import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/animated_vehicle.dart';

class MapState {
  final Map<String, AnimatedVehicle> trackedVehiclesMap;
  final Set<Line> trackedLines;
  final double zoom;
  final LatLngBounds bounds;

  MapState(this.trackedVehiclesMap, this.trackedLines, this.zoom, this.bounds);

  MapState.empty()
      : trackedVehiclesMap = {},
        trackedLines = {},
        zoom = MapConstants.initialZoom,
        bounds = null;

  MapState copyWith({
    Map<String, AnimatedVehicle> trackedVehiclesMap,
    Set<Line> trackedLines,
    double zoom,
    LatLngBounds bounds,
  }) {
    return MapState(
      trackedVehiclesMap ?? this.trackedVehiclesMap,
      trackedLines ?? this.trackedLines,
      zoom ?? this.zoom,
      bounds ?? this.bounds,
    );
  }
}
