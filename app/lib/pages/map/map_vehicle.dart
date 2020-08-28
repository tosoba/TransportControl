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
  })  : vehicle = vehicle,
        marker = null,
        sources = sources ?? {};

  MapVehicle.fromNewlyLoadedVehicle(
    Vehicle newlyLoadedVehicle, {
    @required MapVehicleSource source,
  })  : vehicle = newlyLoadedVehicle,
        marker = null,
        sources = {source};

  MapVehicle withUpdatedVehicle(
    Vehicle updatedVehicle, {
    @required LatLngBounds bounds,
    Set<MapVehicleSource> sources,
  }) {
    return MapVehicle._(
      updatedVehicle,
      null,
      sources ?? this.sources,
    );
  }

  MapVehicle withRemovedSource(MapVehicleSource source) {
    return MapVehicle._(vehicle, marker, sources..remove(source));
  }
}
