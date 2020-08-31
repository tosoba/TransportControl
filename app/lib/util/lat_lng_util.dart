import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:latlong/latlong.dart';
import 'package:flutter_animarker/helpers/math_util.dart';
import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:flutter_animarker/models/lat_lng_delta.dart';
import 'package:flutter_animarker/streams/lat_lng_delta_stream.dart';
import 'package:flutter_animarker/streams/lat_lng_stream.dart';

class LatLngInterpolationStream {
  LatLngStream _latLngStream;
  LatLngDeltaStream _latLngRotationStream;
  final Duration movementDuration;
  final Duration rotationDuration;
  final Duration movementInterval;
  final Duration rotationInterval;
  Maps.LatLng _previousLatLng;
  Maps.LatLng _lastInterpolatedPosition;
  StreamSubscription _subscription;
  final Curve curve;

  final int latLngLimit;
  int _latLngCount = 0;

  LatLngInterpolationStream({
    this.curve = Curves.linear,
    this.rotationDuration = const Duration(milliseconds: 600),
    this.movementDuration = const Duration(milliseconds: 1000),
    this.movementInterval = const Duration(milliseconds: 20),
    this.rotationInterval = const Duration(milliseconds: 12),
    this.latLngLimit,
  }) {
    _latLngStream = LatLngStream();
    _latLngRotationStream = LatLngDeltaStream();
  }

  //Add Marker's LatLng for animation processing
  void addLatLng(Maps.LatLng latLng) {
    if (_subscription == null) {
      _subscription = _latLngMovementInterpolation().listen(_rotateLatLng);
    }
    _latLngStream.addLatLng(latLng);
    if (latLngLimit != null && latLngLimit == ++_latLngCount) {
      _latLngRotationStream.dispose();
    }
  }

  ///Rotate markers between two given position
  void _rotateLatLng(LatLngDelta latLng) {
    _latLngRotationStream.addLatLng(latLng);
  }

  Stream<LatLngDelta> getLatLngInterpolation() async* {
    int start = 0; //To determine when the animation has ended
    double lastBearing = 0.0 /
        0.0; //Creation a start position, since any value could be a valida angle
    CurveTween curveTween = CurveTween(curve: curve);

    //Waiting for new incoming LatLng movement
    await for (LatLngDelta deltaPosition in _latLngRotationStream.stream) {
      double angle = SphericalUtil.angleShortestDistance(
          MathUtil.toRadians(lastBearing),
          MathUtil.toRadians(deltaPosition.rotation));
      double angleDelta = MathUtil.toDegrees(angle);

      //No taking angle movement below 25.0 degrees
      if (lastBearing.isNaN || angleDelta.abs() < 25.0) {
        //Saving the position for calculate angle delta
        lastBearing = deltaPosition.rotation;
        //Send the same delta position to the stream buffer, any changes detected
        yield deltaPosition;
        continue;
      }

      //Saving the time in millisecond when the animation start, and calculate the elapsed time
      start = DateTime.now().millisecondsSinceEpoch;
      int elapsed = 0;
      double currentAngle = deltaPosition.rotation;
      //Saving the last angle for rotation animation
      double lastAngle = lastBearing;

      //Iterate meanwhile the rotation duration hasn't completed
      //When the elapsed is equal to the durationRotation the animation is over
      while (elapsed.toDouble() / rotationDuration.inMilliseconds < 1.0) {
        elapsed = DateTime.now().millisecondsSinceEpoch - start;

        double t = (elapsed.toDouble() / rotationDuration.inMilliseconds)
            .clamp(0.0, 1.0);

        //Value of the curve at point `t`;
        double value = curveTween.transform(t);

        double rotation =
            SphericalUtil.angleLerp(lastAngle, currentAngle, value);

        lastBearing = deltaPosition.rotation;
        deltaPosition.rotation = rotation;

        yield deltaPosition;

        await Future.delayed(rotationInterval);
      }
    }
  }

  ///Interpolate just the linear movement of the markers
  Stream<LatLngDelta> _latLngMovementInterpolation() async* {
    double lastBearing = 0;
    int start = 0;

    await for (Maps.LatLng pos in _latLngStream.stream) {
      double distance =
          SphericalUtil.computeDistanceBetween(_previousLatLng ?? pos, pos);

      //First marker, required at least two from have a delta position
      if (_previousLatLng == null || distance < 5.5) {
        _previousLatLng = pos;
        continue;
      }

      start = DateTime.now().millisecondsSinceEpoch;
      int elapsed = 0;

      while (elapsed.toDouble() / movementDuration.inMilliseconds < 1.0) {
        elapsed = DateTime.now().millisecondsSinceEpoch - start;

        double t = elapsed.toDouble() / movementDuration.inMilliseconds;

        Maps.LatLng latLng = SphericalUtil.interpolate(_previousLatLng, pos, t);

        double rotation = SphericalUtil.getBearing(
            latLng, _lastInterpolatedPosition ?? _previousLatLng);

        double diff =
            SphericalUtil.angleShortestDistance(rotation, lastBearing);

        double distance = SphericalUtil.computeDistanceBetween(
            latLng, _lastInterpolatedPosition ?? _previousLatLng);

        //Determine if the marker's has made a significantly movement
        if (diff.isNaN || distance < 1.5) {
          continue;
        }

        yield LatLngDelta(
          from: _lastInterpolatedPosition ?? _previousLatLng,
          to: latLng,
          rotation: !rotation.isNaN ? rotation : lastBearing,
        );

        lastBearing = !rotation.isNaN ? rotation : lastBearing;

        _lastInterpolatedPosition = latLng;

        await Future.delayed(movementInterval);
      }
      _previousLatLng = _lastInterpolatedPosition;
    }
  }

  void cancel() {
    _subscription.cancel();
  }
}

extension LatLngExt on Maps.LatLngBounds {
  bool containsLatLng(double latitude, double longitude) {
    final containsLat =
        (southwest.latitude <= latitude) && (latitude <= northeast.latitude);
    final containsLng = southwest.longitude <= northeast.longitude
        ? southwest.longitude <= longitude && longitude <= northeast.longitude
        : southwest.longitude <= longitude || longitude <= northeast.longitude;
    return containsLat && containsLng;
  }

  static final Distance _distance = const Distance();

  Maps.CameraPosition get cameraPosition {
    final center = LatLng(
      (northeast.latitude + southwest.latitude) / 2,
      (northeast.longitude + southwest.longitude) / 2,
    );
    final distance = _distance(
      center,
      LatLng(northeast.latitude, northeast.longitude),
    );
    final scale = distance / 1000;
    final zoom = 16 - log(scale) / log(2);
    return Maps.CameraPosition(
      target: Maps.LatLng(center.latitude, center.longitude),
      zoom: zoom,
    );
  }
}

extension LatLngListExt on Iterable<Maps.LatLng> {
  Maps.LatLngBounds get bounds {
    assert(isNotEmpty);
    double x0, x1, y0, y1;
    for (final latLng in this) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return Maps.LatLngBounds(
      northeast: Maps.LatLng(x1, y1),
      southwest: Maps.LatLng(x0, y0),
    );
  }
}
