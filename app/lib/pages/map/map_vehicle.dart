import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_position_animation.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
import 'package:transport_control/util/model_util.dart';

class MapVehicle {
  final Vehicle vehicle;
  final MapPositionAnimation animation;
  final Set<MapVehicleSource> sources;

  MapVehicle._(this.vehicle, this.animation, this.sources);

  MapVehicle.fromNewlyLoadedVehicle(
    Vehicle newlyLoadedVehicle, {
    @required MapVehicleSource source,
  })  : vehicle = newlyLoadedVehicle,
        animation = MapPositionAnimation.first(newlyLoadedVehicle.position),
        sources = Set()..add(source);

  Future<MapVehicle> withUpdatedVehicle(
    Vehicle updatedVehicle, {
    @required Maps.LatLngBounds bounds,
    @required double zoom,
    @required int mapId,
    Set<MapVehicleSource> sources,
  }) async {
    return MapVehicle._(
      updatedVehicle,
      await animation.withUpdatedPosition(
        updatedVehicle.position,
        bounds: bounds,
        zoom: zoom,
        mapId: mapId,
      ),
      sources ?? this.sources,
    );
  }

  MapVehicle toNextStage({
    @required Maps.LatLngBounds bounds,
    @required double zoom,
  }) {
    return MapVehicle._(
      vehicle,
      animation.toNextStage(bounds: bounds, zoom: zoom),
      sources,
    );
  }

  MapVehicle withRemovedSource(MapVehicleSource source) {
    return MapVehicle._(vehicle, animation, sources..remove(source));
  }
}
