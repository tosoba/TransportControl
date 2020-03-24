import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:latlong/latlong.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/util/lat_lng_ext.dart';

class AnimatedVehicle {
  final Vehicle vehicle;
  final _VehicleAnimationStage stage;

  AnimatedVehicle.fromNewlyLoaded(Vehicle newlyLoadedVehicle)
      : vehicle = newlyLoadedVehicle,
        stage = _VehicleAnimationStage.forNewlyLoadedVehicle(
          newlyLoadedVehicle,
        );

  AnimatedVehicle.fromUpdated(
    Vehicle updatedVehicle, {
    @required _VehicleAnimationStage previous,
    @required Maps.LatLngBounds currentBounds,
    @required double currentZoom,
  })  : vehicle = updatedVehicle,
        stage = _VehicleAnimationStage.forUpdatedVehicle(
          updatedVehicle,
          previous,
          currentBounds,
          currentZoom,
        );

  AnimatedVehicle.nextStageOf(
    AnimatedVehicle animatedVehicle, {
    @required Maps.LatLngBounds currentBounds,
    @required double currentZoom,
  })  : vehicle = animatedVehicle.vehicle,
        stage = _VehicleAnimationStage.nextStage(
          animatedVehicle.stage,
          currentBounds,
          currentZoom,
        );
}

class _VehicleAnimationStage {
  LatLng _start;
  LatLng _current;
  LatLng _dest;
  int _animationStartTime;
  bool _isAnimating;
  int _durationMillis;

  static final Distance distance = const Distance();
  static final double _animationThreshold = 12.5;

  bool get isAnimating => _isAnimating;
  LatLng get current => _current;

  _VehicleAnimationStage.forNewlyLoadedVehicle(Vehicle newlyLoadedVehicle)
      : _start = null,
        _current = LatLng(newlyLoadedVehicle.lat, newlyLoadedVehicle.lon),
        _dest = null,
        _animationStartTime = null,
        _isAnimating = false,
        _durationMillis = null;

  _VehicleAnimationStage.forUpdatedVehicle(
    Vehicle updatedVehicle,
    _VehicleAnimationStage previousStage,
    Maps.LatLngBounds currentBounds,
    double currentZoom,
  ) {
    final dest = LatLng(updatedVehicle.lat, updatedVehicle.lon);
    if (shouldAnimate(previousStage, currentBounds, currentZoom, dest)) {
      _start = previousStage._current;
      _current = previousStage._current;
      _dest = dest;
      _animationStartTime = DateTime.now().millisecondsSinceEpoch;
      _isAnimating = true;
      initDurationMillis();
    } else {
      _start = null;
      _current = LatLng(updatedVehicle.lat, updatedVehicle.lon);
      _dest = null;
      _animationStartTime = null;
      _isAnimating = false;
      _durationMillis = null;
    }
  }

  bool shouldAnimate(
    _VehicleAnimationStage previousStage,
    Maps.LatLngBounds currentBounds,
    double currentZoom,
    LatLng dest,
  ) {
    return currentZoom > _animationThreshold &&
        (currentBounds.containsLatLng(previousStage._current) ||
            currentBounds.containsLatLng(dest));
  }

  void initDurationMillis() {
    final startDestDistance = distance(_start, _dest);
    if (startDestDistance < 200)
      _durationMillis = 500;
    else if (startDestDistance < 500)
      _durationMillis = 1000;
    else
      _durationMillis = 1500;
  }

  _VehicleAnimationStage.nextStage(
    _VehicleAnimationStage previousStage,
    Maps.LatLngBounds currentBounds,
    double currentZoom,
  ) {
    if (shouldAnimate(
        previousStage, currentBounds, currentZoom, previousStage._dest)) {
      _start = previousStage._start;

      final elapsedMillis = previousStage.elapsed;
      final multiplier = previousStage.interpolation(elapsedMillis);
      final lng = multiplier * previousStage._dest.longitude +
          (1 - multiplier) * previousStage._start.longitude;
      final lat = multiplier * previousStage._dest.latitude +
          (1 - multiplier) * previousStage._start.latitude;
      _current = LatLng(lat, lng);

      _dest = previousStage._dest;
      _animationStartTime = previousStage._animationStartTime;
      _durationMillis = previousStage._durationMillis;
      _isAnimating = elapsedMillis < _durationMillis;
    } else {
      _start = null;
      _current = previousStage._dest;
      _dest = null;
      _animationStartTime = null;
      _isAnimating = false;
      _durationMillis = null;
    }
  }

  int get elapsed =>
      DateTime.now().millisecondsSinceEpoch - _animationStartTime;

  double interpolation(int elapsedMillis) {
    if (!_isAnimating) throw ArgumentError();
    return (cos(((elapsedMillis / _durationMillis) + 1) * pi) / 2.0) + 0.5;
  }
}
