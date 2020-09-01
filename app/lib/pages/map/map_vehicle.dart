import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';

class MapVehicle {
  final Vehicle vehicle;
  final Marker marker;
  final Set<MapVehicleSource> sources;

  MapVehicle._(this.vehicle, this.marker, this.sources);

  MapVehicle.withoutMarker(
    Vehicle vehicle, {
    Set<MapVehicleSource> sources,
  })  : assert(vehicle != null),
        vehicle = vehicle,
        marker = null,
        sources = sources ?? {};

  MapVehicle.withMarker(
    Vehicle vehicle, {
    @required Marker marker,
    Set<MapVehicleSource> sources,
  })  : assert(vehicle != null),
        vehicle = vehicle,
        marker = marker,
        sources = sources ?? {};

  MapVehicle withRemovedSource(MapVehicleSource source) {
    return MapVehicle._(vehicle, marker, sources..remove(source));
  }
}
