import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';

class MapVehicle {
  final Vehicle vehicle;
  final List<LatLng> previousPositions;
  final Set<MapVehicleSource> sources;

  MapVehicle._(this.vehicle, this.previousPositions, this.sources);

  MapVehicle.fromNewlyLoadedVehicle(
    Vehicle newlyLoadedVehicle, {
    @required MapVehicleSource source,
  })  : vehicle = newlyLoadedVehicle,
        previousPositions = List.empty(),
        sources = Set()..add(source);

  MapVehicle withUpdatedVehicle(
    Vehicle updatedVehicle, {
    @required LatLngBounds bounds,
    Set<MapVehicleSource> sources,
  }) {
    return MapVehicle._(
      updatedVehicle,
      (updatedVehicle.lat == vehicle.lat && updatedVehicle.lon == vehicle.lon)
          ? List.empty()
          : [LatLng(vehicle.lat, vehicle.lon)],
      sources ?? this.sources,
    );
  }

  MapVehicle withRemovedSource(MapVehicleSource source) {
    return MapVehicle._(vehicle, previousPositions, sources..remove(source));
  }
}
