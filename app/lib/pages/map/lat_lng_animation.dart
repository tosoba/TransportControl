import 'dart:math';

import 'package:latlong/latlong.dart';

class LatLngAnimation {
  final double startLat;
  final double startLon;
  final double destLat;
  final double destLon;
  final int animationStartTime;
  final bool isAnimating;

  int _durationMillis;

  final Distance distance = const Distance();

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

  int get elapsed => DateTime.now().millisecondsSinceEpoch - animationStartTime;

  double get startDestDistance {
    return distance(
      LatLng(startLat, startLon),
      LatLng(destLat, destLon),
    );
  }

  double get interpolation {
    return (cos(((elapsed / _durationMillis) + 1) * pi) / 2.0) + 0.5;
  }
}
