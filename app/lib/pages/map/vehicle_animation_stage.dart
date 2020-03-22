import 'dart:math';

import 'package:latlong/latlong.dart';
import 'package:transport_control/model/vehicle.dart';

class AnimatedVehicle {
  final Vehicle vehicle;
  final _VehicleAnimationStage stage;

  AnimatedVehicle.fromNewlyLoadedVehicle(Vehicle newlyLoadedVehicle)
      : vehicle = newlyLoadedVehicle,
        stage = _VehicleAnimationStage.forNewlyLoadedVehicle(newlyLoadedVehicle);

  AnimatedVehicle.fromUpdatedVehicle(
    Vehicle updatedVehicle,
    AnimatedVehicle previous,
  )   : vehicle = updatedVehicle,
        stage = _VehicleAnimationStage.forUpdatedVehicle(
          updatedVehicle,
          previous.stage,
        );

  AnimatedVehicle.nextStage(AnimatedVehicle previous)
      : vehicle = previous.vehicle,
        stage = _VehicleAnimationStage.nextStage(previous.stage);
}

class _VehicleAnimationStage {
  final LatLng start;
  LatLng _current;
  final LatLng dest;
  final int animationStartTime;
  bool _isAnimating;
  int _durationMillis;

  static final Distance distance = const Distance();

  bool get isAnimating => _isAnimating;
  LatLng get current => _current;

  _VehicleAnimationStage.forNewlyLoadedVehicle(Vehicle newlyLoadedVehicle)
      : start = null,
        _current = LatLng(newlyLoadedVehicle.lat, newlyLoadedVehicle.lon),
        dest = null,
        animationStartTime = null,
        _isAnimating = false,
        _durationMillis = null;

  _VehicleAnimationStage.forUpdatedVehicle(
    Vehicle updatedVehicle,
    _VehicleAnimationStage previousStage,
  )   : start = previousStage._current,
        _current = previousStage._current,
        dest = LatLng(updatedVehicle.lat, updatedVehicle.lon),
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

  _VehicleAnimationStage.nextStage(_VehicleAnimationStage previousStage)
      : start = previousStage.start,
        dest = previousStage.dest,
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
