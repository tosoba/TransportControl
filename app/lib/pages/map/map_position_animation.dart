import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:latlong/latlong.dart';
import 'package:transport_control/util/lat_lng_util.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as MapsPlatform;

class MapPositionAnimation {
  final LatLng position;
  final _AnimationStage stage;

  MapPositionAnimation._(this.position, this.stage);

  MapPositionAnimation.first(LatLng position)
      : position = position,
        stage = _AnimationStage.first(position);

  Future<MapPositionAnimation> withUpdatedPosition(
    LatLng position, {
    @required Maps.LatLngBounds bounds,
    @required double zoom,
    @required int mapId,
  }) async {
    return MapPositionAnimation._(
      position,
      await stage.forUpdatedPosition(
        position,
        bounds: bounds,
        zoom: zoom,
        mapId: mapId,
      ),
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

  static final double _animationMinZoom = 12.5;

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

  Future<_AnimationStage> forUpdatedPosition(
    LatLng updatedPosition, {
    @required Maps.LatLngBounds bounds,
    @required double zoom,
    @required int mapId,
  }) async {
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
        .._durationMillis = await _durationMillisFor(
          zoom: zoom,
          start: _current,
          dest: updatedPosition,
          mapId: mapId,
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
      final isAnimating = elapsedMillis < _durationMillis;
      if (isAnimating) {
        final multiplier = _interpolation(elapsedMillis);
        final lng =
            multiplier * _dest.longitude + (1 - multiplier) * _start.longitude;
        final lat =
            multiplier * _dest.latitude + (1 - multiplier) * _start.latitude;
        nextStage._current = LatLng(lat, lng);
      } else {
        nextStage._current = _dest;
      }
      nextStage._dest = _dest;
      nextStage._animationStartTime = _animationStartTime;
      nextStage._durationMillis = _durationMillis;
      nextStage._isAnimating = isAnimating;
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
    return zoom > _animationMinZoom &&
        (bounds.containsLatLng(_current) || bounds.containsLatLng(dest));
  }

  int get _elapsed {
    return DateTime.now().millisecondsSinceEpoch - _animationStartTime;
  }

  double _interpolation(int elapsedMillis) {
    if (!_isAnimating) throw ArgumentError();
    return (cos(((elapsedMillis / _durationMillis) + 1) * pi) / 2.0) + 0.5;
  }

  static Future<int> _durationMillisFor({
    @required double zoom,
    @required LatLng start,
    @required LatLng dest,
    @required int mapId,
  }) async {
    final platform = MapsPlatform.GoogleMapsFlutterPlatform.instance;
    final coordinates = await Future.wait([
      platform.getScreenCoordinate(
        Maps.LatLng(start.latitude, start.longitude),
        mapId: mapId,
      ),
      platform.getScreenCoordinate(
        Maps.LatLng(dest.latitude, dest.longitude),
        mapId: mapId,
      ),
    ]);
    final startCoordinate = coordinates[0];
    final destCoordinate = coordinates[1];
    final coordinateDistance = sqrt(
      pow(destCoordinate.x - startCoordinate.x, 2) +
          pow(destCoordinate.y - startCoordinate.y, 2),
    );
    return (coordinateDistance * 16).toInt();
  }
}
