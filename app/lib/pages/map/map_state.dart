part of 'package:transport_control/pages/map/map_bloc.dart';

class MapState {
  final Set<Vehicle> trackedVehicles;
  final Set<Line> trackedLines;

  MapState(this.trackedVehicles, this.trackedLines);

  MapState.empty()
      : trackedVehicles = {},
        trackedLines = {};
}

class LatLngAnimation {
  final double startLat;
  final double startLon;
  final double destLat;
  final double destLon;
  final int animationStartTime;
  final bool isAnimating;

  int _durationMillis;

  LatLngAnimation(
    this.startLat,
    this.startLon,
    this.destLat,
    this.destLon,
    this.animationStartTime,
    this.isAnimating,
  ) {
    final distance = startDestDistance;
    if (distance < 200)
      _durationMillis = 500;
    else if (distance < 500)
      _durationMillis = 1000;
    else
      _durationMillis = 1500;
  }

  int get elapsed => throw UnimplementedError();

  double get startDestDistance {
    throw UnimplementedError();
  }

  double get interpolation {
    throw UnimplementedError();
  }
}
