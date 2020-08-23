import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';

class MapVehicle {
  final Vehicle vehicle;
  final Set<MapVehicleSource> sources;

  MapVehicle._(this.vehicle, this.sources);

  MapVehicle.fromNewlyLoadedVehicle(
    Vehicle newlyLoadedVehicle, {
    @required MapVehicleSource source,
  })  : vehicle = newlyLoadedVehicle,
        sources = Set()..add(source);

  MapVehicle withUpdatedVehicle(
    Vehicle updatedVehicle, {
    @required LatLngBounds bounds,
    Set<MapVehicleSource> sources,
  }) {
    return MapVehicle._(updatedVehicle, sources ?? this.sources);
  }

  MapVehicle toNextStage({
    @required LatLngBounds bounds,
    @required double zoom,
  }) {
    return MapVehicle._(vehicle, sources);
  }

  MapVehicle withRemovedSource(MapVehicleSource source) {
    return MapVehicle._(vehicle, sources..remove(source));
  }
}
