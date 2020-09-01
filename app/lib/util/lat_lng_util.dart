import 'dart:math';

import 'package:flutter_animarker/helpers/spherical_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension LatLngExt on LatLngBounds {
  bool containsLatLng(double latitude, double longitude) {
    final containsLat =
        (southwest.latitude <= latitude) && (latitude <= northeast.latitude);
    final containsLng = southwest.longitude <= northeast.longitude
        ? southwest.longitude <= longitude && longitude <= northeast.longitude
        : southwest.longitude <= longitude || longitude <= northeast.longitude;
    return containsLat && containsLng;
  }

  CameraPosition get cameraPosition {
    final center = LatLng(
      (northeast.latitude + southwest.latitude) / 2,
      (northeast.longitude + southwest.longitude) / 2,
    );
    final distance = SphericalUtil.computeDistanceBetween(center, northeast);
    final scale = distance / 1000;
    final zoom = 16 - log(scale) / log(2);
    return CameraPosition(target: center, zoom: zoom);
  }
}

extension LatLngListExt on Iterable<LatLng> {
  LatLngBounds get bounds {
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
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }
}
