import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';

class MapVehicle {
  final Vehicle vehicle;
  final LatLng previousPosition;
  final Set<MapVehicleSource> sources;

  MapVehicle._(this.vehicle, this.previousPosition, this.sources);

  MapVehicle.fromNewlyLoadedVehicle(
    Vehicle newlyLoadedVehicle, {
    @required MapVehicleSource source,
  })  : vehicle = newlyLoadedVehicle,
        previousPosition = null,
        sources = Set()..add(source);

  MapVehicle withUpdatedVehicle(
    Vehicle updatedVehicle, {
    @required LatLngBounds bounds,
    Set<MapVehicleSource> sources,
  }) {
    return MapVehicle._(
      updatedVehicle,
      LatLng(vehicle.lat, vehicle.lon),
      sources ?? this.sources,
    );
  }

  MapVehicle withRemovedSource(MapVehicleSource source) {
    return MapVehicle._(vehicle, previousPosition, sources..remove(source));
  }
}
