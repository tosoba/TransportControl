import 'dart:math';

import 'package:latlong/latlong.dart';
import 'package:transport_control/model/vehicle.dart';

class VehicleAnimationStage {
  final LatLng start;
  LatLng _current;
  final LatLng dest;
  final String lastUpdate;
  final int animationStartTime;
  bool _isAnimating;
  int _durationMillis;

  static final Distance distance = const Distance();

  bool get isAnimating => _isAnimating;
  LatLng get current => _current;

  VehicleAnimationStage.forNewlyLoadedVehicle(Vehicle newlyLoadedVehicle)
      : start = null,
        _current = LatLng(newlyLoadedVehicle.lat, newlyLoadedVehicle.lon),
        dest = null,
        lastUpdate = newlyLoadedVehicle.lastUpdate,
        animationStartTime = null,
        _isAnimating = false,
        _durationMillis = null;

  VehicleAnimationStage.forUpdatedVehiclePosition(
    Vehicle updatedVehicle,
    VehicleAnimationStage previousStage,
  )   : start = previousStage._current,
        _current = previousStage._current,
        dest = LatLng(updatedVehicle.lat, updatedVehicle.lon),
        lastUpdate = updatedVehicle.lastUpdate,
        animationStartTime = DateTime.now().millisecondsSinceEpoch,
        _isAnimating = true {
    initDurationMillis();
  }

  void initDurationMillis() {
    final startDestDistance = distance(start, dest);
    if (startDestDistance < 200)
      _durationMillis = 500;
    else if (startDestDistance < 500)
      _durationMillis = 1000;
    else
      _durationMillis = 1500;
  }

  VehicleAnimationStage.nextStage(VehicleAnimationStage previousStage)
      : start = previousStage.start,
        dest = previousStage.dest,
        lastUpdate = previousStage.lastUpdate,
        animationStartTime = previousStage.animationStartTime,
        _durationMillis = previousStage._durationMillis {
    final elapsedMillis = previousStage.elapsed;
    final multiplier = previousStage.interpolation(elapsedMillis);
    final lng = multiplier * previousStage.dest.longitude +
        (1 - multiplier) * previousStage.start.longitude;
    final lat = multiplier * previousStage.dest.latitude +
        (1 - multiplier) * previousStage.start.latitude;
    _current = LatLng(lat, lng);
    _isAnimating = elapsedMillis < _durationMillis;
  }

  int get elapsed => DateTime.now().millisecondsSinceEpoch - animationStartTime;

  double interpolation(int elapsedMillis) {
    if (!_isAnimating) throw ArgumentError();
    return (cos(((elapsedMillis / _durationMillis) + 1) * pi) / 2.0) + 0.5;
  }
}
