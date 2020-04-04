import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';

class MapState {
  final Map<String, MapVehicle> trackedVehicles;
  final double zoom;
  final LatLngBounds bounds;

  MapState(this.trackedVehicles, this.zoom, this.bounds);

  MapState.empty()
      : trackedVehicles = {},
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
      zoom ?? this.zoom,
      bounds ?? this.bounds,
    );
  }
}
