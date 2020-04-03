import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:latlong/latlong.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/vehicle_source.dart';
import 'package:transport_control/util/lat_lng_ext.dart';

class AnimatedVehicle {
  final Vehicle vehicle;
  final _VehicleAnimationStage stage;
  final Set<VehicleSource> sources;

  AnimatedVehicle._(this.vehicle, this.stage, this.sources);

  AnimatedVehicle.fromNewlyLoadedVehicle(
    Vehicle newlyLoadedVehicle, {
    @required VehicleSource source,
  })  : vehicle = newlyLoadedVehicle,
        stage = _VehicleAnimationStage.forNewlyLoadedVehicle(
          newlyLoadedVehicle,
        ),
        sources = Set()..add(source);

  AnimatedVehicle withUpdatedVehicle(
    Vehicle updatedVehicle, {
    @required Maps.LatLngBounds currentBounds,
    @required double currentZoom,
    Set<VehicleSource> sources,
  }) {
    return AnimatedVehicle._(
      updatedVehicle,
      stage.forUpdatedVehicle(
        updatedVehicle,
        currentBounds,
        currentZoom,
      ),
      sources ?? this.sources,
    );
  }

  AnimatedVehicle toNextStage({
    @required Maps.LatLngBounds currentBounds,
    @required double currentZoom,
  }) {
    return AnimatedVehicle._(
      vehicle,
      stage.nextStage(
        currentBounds,
        currentZoom,
      ),
      sources,
    );
  }

  AnimatedVehicle withRemovedSource(VehicleSource source) {
    return AnimatedVehicle._(
      vehicle,
      stage,
      sources..remove(source),
    );
  }
}

class _VehicleAnimationStage {
  LatLng _start;
  LatLng _current;
  LatLng _dest;
  int _animationStartTime;
  int _durationMillis;
  bool _isAnimating;

  static final Distance _distance = const Distance();
  static final double _animationThreshold = 12.5;

  bool get isAnimating => _isAnimating;
  LatLng get current => _current;

  _VehicleAnimationStage._();

  _VehicleAnimationStage.forNewlyLoadedVehicle(Vehicle newlyLoadedVehicle)
      : _start = null,
        _current = LatLng(newlyLoadedVehicle.lat, newlyLoadedVehicle.lon),
        _dest = null,
        _animationStartTime = null,
        _durationMillis = null,
        _isAnimating = false;

  _VehicleAnimationStage forUpdatedVehicle(
    Vehicle updatedVehicle,
    Maps.LatLngBounds currentBounds,
    double currentZoom,
  ) {
    final dest = LatLng(updatedVehicle.lat, updatedVehicle.lon);
    if (_shouldAnimate(bounds: currentBounds, zoom: currentZoom, dest: dest)) {
      return _VehicleAnimationStage._()
        .._start = _current
        .._current = _current
        .._dest = dest
        .._animationStartTime = DateTime.now().millisecondsSinceEpoch
        .._durationMillis = _durationMillisFor(
          zoom: currentZoom,
          start: _current,
          dest: dest,
        )
        .._isAnimating = true;
    } else {
      return _VehicleAnimationStage._()
        .._start = null
        .._current = LatLng(updatedVehicle.lat, updatedVehicle.lon)
        .._dest = null
        .._animationStartTime = null
        .._durationMillis = null
        .._isAnimating = false;
    }
  }

  bool _shouldAnimate({
    @required Maps.LatLngBounds bounds,
    @required double zoom,
    @required LatLng dest,
  }) {
    return zoom > _animationThreshold &&
        (bounds.containsLatLng(_current) || bounds.containsLatLng(dest));
  }

  static int _durationMillisFor({
    @required double zoom,
    @required LatLng start,
    @required LatLng dest,
  }) {
    final startDestDistance = _distance(start, dest);
    if (startDestDistance < 200)
      return (500 * _durationMultiplierFor(zoom)).toInt();
    else if (startDestDistance < 500)
      return (1000 * _durationMultiplierFor(zoom)).toInt();
    else
      return (1500 * _durationMultiplierFor(zoom)).toInt();
  }

  static double _durationMultiplierFor(double zoom) {
    if (zoom < 13) {
      return 0.8;
    } else if (zoom < 15) {
      return 1;
    } else if (zoom < 17) {
      return 1.1;
    } else if (zoom < 19) {
      return 1.3;
    } else {
      return 1.5;
    }
  }

  _VehicleAnimationStage nextStage(
    Maps.LatLngBounds currentBounds,
    double currentZoom,
  ) {
    if (_shouldAnimate(bounds: currentBounds, zoom: currentZoom, dest: _dest)) {
      final nextStage = _VehicleAnimationStage._().._start = _start;
      final elapsedMillis = _elapsed;
      final multiplier = _interpolation(elapsedMillis);
      final lng =
          multiplier * _dest.longitude + (1 - multiplier) * _start.longitude;
      final lat =
          multiplier * _dest.latitude + (1 - multiplier) * _start.latitude;
      nextStage._current = LatLng(lat, lng);
      nextStage._dest = _dest;
      nextStage._animationStartTime = _animationStartTime;
      nextStage._durationMillis = _durationMillis;
      nextStage._isAnimating = elapsedMillis < _durationMillis;
      return nextStage;
    } else {
      return _VehicleAnimationStage._()
        .._start = null
        .._current = _dest
        .._dest = null
        .._animationStartTime = null
        .._durationMillis = null
        .._isAnimating = false;
    }
  }

  int get _elapsed {
    return DateTime.now().millisecondsSinceEpoch - _animationStartTime;
  }

  double _interpolation(int elapsedMillis) {
    if (!_isAnimating) throw ArgumentError();
    return (cos(((elapsedMillis / _durationMillis) + 1) * pi) / 2.0) + 0.5;
  }
}
