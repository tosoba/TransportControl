import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:latlong/latlong.dart';
import 'package:transport_control/util/lat_lng_util.dart';

class MapPositionAnimation {
  final LatLng position;
  final _AnimationStage stage;

  MapPositionAnimation._(this.position, this.stage);

  MapPositionAnimation.first(LatLng position)
      : position = position,
        stage = _AnimationStage.first(position);

  MapPositionAnimation withUpdatedPosition(
    LatLng position, {
    @required Maps.LatLngBounds bounds,
    @required double zoom,
  }) {
    return MapPositionAnimation._(
      position,
      stage.forUpdatedPosition(position, bounds: bounds, zoom: zoom),
    );
  }

  MapPositionAnimation toNextStage({
    @required Maps.LatLngBounds bounds,
    @required double zoom,
  }) {
    return MapPositionAnimation._(
      position,
      stage.next(bounds: bounds, zoom: zoom),
    );
  }
}

class _AnimationStage {
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

  _AnimationStage._();

  _AnimationStage.first(LatLng position)
      : _start = null,
        _current = position,
        _dest = null,
        _animationStartTime = null,
        _durationMillis = null,
        _isAnimating = false;

  _AnimationStage forUpdatedPosition(
    LatLng updatedPosition, {
    @required Maps.LatLngBounds bounds,
    @required double zoom,
  }) {
    if (_shouldAnimate(
      bounds: bounds,
      zoom: zoom,
      dest: updatedPosition,
    )) {
      return _AnimationStage._()
        .._start = _current
        .._current = _current
        .._dest = updatedPosition
        .._animationStartTime = DateTime.now().millisecondsSinceEpoch
        .._durationMillis = _durationMillisFor(
          zoom: zoom,
          start: _current,
          dest: updatedPosition,
        )
        .._isAnimating = true;
    } else {
      return _AnimationStage._()
        .._start = null
        .._current = updatedPosition
        .._dest = null
        .._animationStartTime = null
        .._durationMillis = null
        .._isAnimating = false;
    }
  }

  _AnimationStage next({
    @required Maps.LatLngBounds bounds,
    @required double zoom,
  }) {
    if (_shouldAnimate(bounds: bounds, zoom: zoom, dest: _dest)) {
      final nextStage = _AnimationStage._().._start = _start;
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
      return _AnimationStage._()
        .._start = null
        .._current = _dest
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

  int get _elapsed {
    return DateTime.now().millisecondsSinceEpoch - _animationStartTime;
  }

  double _interpolation(int elapsedMillis) {
    if (!_isAnimating) throw ArgumentError();
    return (cos(((elapsedMillis / _durationMillis) + 1) * pi) / 2.0) + 0.5;
  }

  static int _durationMillisFor({
    @required double zoom,
    @required LatLng start,
    @required LatLng dest,
  }) {
    final startDestDistance = _distance(start, dest);
    if (startDestDistance < 200)
      return (250 * _durationMultiplierFor(zoom)).toInt();
    else if (startDestDistance < 500)
      return (500 * _durationMultiplierFor(zoom)).toInt();
    else
      return (1000 * _durationMultiplierFor(zoom)).toInt();
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
}
