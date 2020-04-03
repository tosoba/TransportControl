import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';

class MapState {
  final Map<String, MapVehicle> trackedVehicles;
  final Set<Line> trackedLines;
  final double zoom;
  final LatLngBounds bounds;

  MapState(this.trackedVehicles, this.trackedLines, this.zoom, this.bounds);

  MapState.empty()
      : trackedVehicles = {},
        trackedLines = {},
        zoom = MapConstants.initialZoom,
        bounds = null;

  MapState copyWith({
    Map<String, MapVehicle> trackedVehicles,
    Set<Line> trackedLines,
    double zoom,
    LatLngBounds bounds,
  }) {
    return MapState(
      trackedVehicles ?? this.trackedVehicles,
      trackedLines ?? this.trackedLines,
      zoom ?? this.zoom,
      bounds ?? this.bounds,
    );
  }
}
