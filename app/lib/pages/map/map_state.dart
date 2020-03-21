part of 'package:transport_control/pages/map/map_bloc.dart';

class MapState {
  final Set<Vehicle> trackedVehicles;
  final Set<Line> trackedLines;

  MapState(this.trackedVehicles, this.trackedLines);

  MapState.empty()
      : trackedVehicles = {},
        trackedLines = {};
}

class AnimatedVehicle {
  final Vehicle vehicle;
  final double nextLat;
  final double nextLon;
  final int animationStartTime;

  AnimatedVehicle(
    this.vehicle,
    this.nextLat,
    this.nextLon,
    this.animationStartTime,
  );
}
