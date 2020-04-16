import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/pages/map/map_constants.dart';
import 'package:transport_control/pages/map/map_vehicle.dart';

class MapState {
  final Map<String, MapVehicle> trackedVehicles;
  final double zoom;
  final LatLngBounds bounds;
  final String selectedVehicleNumber;

  MapState._({
    @required this.trackedVehicles,
    @required this.zoom,
    @required this.bounds,
    @required this.selectedVehicleNumber,
  });

  MapState.initial()
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
    return MapState._(
      trackedVehicles: trackedVehicles ?? this.trackedVehicles,
      zoom: zoom ?? this.zoom,
      bounds: bounds ?? this.bounds,
      selectedVehicleNumber:
          selectedVehicleNumber ?? this.selectedVehicleNumber,
    );
  }

  MapState get withNoSelectedVehicle {
    return MapState._(
      trackedVehicles: trackedVehicles,
      zoom: zoom,
      bounds: bounds,
      selectedVehicleNumber: null,
    );
  }
}
