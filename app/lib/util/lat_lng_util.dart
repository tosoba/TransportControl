import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:latlong/latlong.dart';

extension LatLngExt on Maps.LatLngBounds {
  bool containsLatLng(LatLng latLng) {
    final containsLat = (southwest.latitude <= latLng.latitude) &&
        (latLng.latitude <= northeast.latitude);
    final containsLng = southwest.longitude <= northeast.longitude
        ? southwest.longitude <= latLng.longitude &&
            latLng.longitude <= northeast.longitude
        : southwest.longitude <= latLng.longitude ||
            latLng.longitude <= northeast.longitude;
    return containsLat && containsLng;
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
