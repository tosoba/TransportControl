import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';

class MapState {
  final Map<String, MapVehicle> trackedVehicles;
  final double zoom;
  final LatLngBounds bounds;
  final String selectedVehicleNumber;

  MapState(
    this.trackedVehicles,
    this.zoom,
    this.bounds,
    this.selectedVehicleNumber,
  );

  MapState.empty()
      : trackedVehicles = {},
        zoom = MapConstants.initialZoom,
        bounds = null,
        selectedVehicleNumber = null;

  MapState copyWith({
    Map<String, MapVehicle> trackedVehicles,
    double zoom,
    LatLngBounds bounds,
    String selectedVehicleNumber,
  }) {
    return MapState(
      trackedVehicles ?? this.trackedVehicles,
      zoom ?? this.zoom,
      bounds ?? this.bounds,
      selectedVehicleNumber ?? this.selectedVehicleNumber,
    );
  }

  MapState get withNoSelectedVehicle => MapState(
        trackedVehicles,
        zoom,
        bounds,
        null,
      );
}
