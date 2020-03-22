import 'dart:math';

import 'package:latlong/latlong.dart';
import 'package:transport_control/model/vehicle.dart';

class VehicleAnimationStage {
  final double startLat;
  final double startLon;
  final double destLat;
  final double destLon;
  final double currentLat;
  final double currentLon;
  final String lastUpdate;
  final int animationStartTime;
  final bool isAnimating;

  int _durationMillis;

  final Distance distance = const Distance();

  VehicleAnimationStage(
    this.startLat,
    this.startLon,
    this.destLat,
    this.destLon,
    this.currentLat,
    this.currentLon,
    this.lastUpdate,
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

  VehicleAnimationStage.forNewlyLoadedVehicle(Vehicle newlyLoadedVehicle)
      : startLat = null,
        startLon = null,
        destLat = null,
        destLon = null,
        currentLat = newlyLoadedVehicle.lat,
        currentLon = newlyLoadedVehicle.lon,
        lastUpdate = newlyLoadedVehicle.lastUpdate,
        animationStartTime = null,
        isAnimating = false;

  VehicleAnimationStage.forUpdatedVehiclePosition(
    Vehicle updatedVehicle,
    VehicleAnimationStage previousStage,
  )   : startLat = previousStage.currentLat,
        startLon = previousStage.currentLon,
        destLat = updatedVehicle.lat,
        destLon = updatedVehicle.lon,
        currentLat = previousStage.currentLat,
        currentLon = previousStage.currentLon,
        lastUpdate = updatedVehicle.lastUpdate,
        animationStartTime = DateTime.now().millisecondsSinceEpoch,
        isAnimating = true;

  VehicleAnimationStage.nextStage(VehicleAnimationStage previousStage)
      : startLat = previousStage.startLat,
        startLon = previousStage.startLon,
        destLat = previousStage.destLat,
        destLon = previousStage.destLon,
        currentLat = previousStage.currentLat,
        currentLon = previousStage.currentLon,
        lastUpdate = previousStage.lastUpdate,
        animationStartTime = previousStage.animationStartTime,
        isAnimating = true;

  int get elapsed => DateTime.now().millisecondsSinceEpoch - animationStartTime;

  double get startDestDistance {
    return distance(
      LatLng(startLat, startLon),
      LatLng(destLat, destLon),
    );
  }

  double get interpolation {
    if (!isAnimating) throw ArgumentError();
    return (cos(((elapsed / _durationMillis) + 1) * pi) / 2.0) + 0.5;
  }
}
