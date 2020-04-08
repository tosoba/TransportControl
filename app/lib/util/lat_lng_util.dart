import 'package:google_maps_flutter/google_maps_flutter.dart' as Maps;
import 'package:latlong/latlong.dart';

extension LatLngExt on Maps.LatLngBounds {
  bool containsLatLng(LatLng latLng) {
    bool containsLat = (southwest.latitude <= latLng.latitude) &&
        (latLng.latitude <= northeast.latitude);
    bool containsLng = southwest.longitude <= northeast.longitude
        ? southwest.longitude <= latLng.longitude &&
            latLng.longitude <= northeast.longitude
        : southwest.longitude <= latLng.longitude ||
            latLng.longitude <= northeast.longitude;
    return containsLat && containsLng;
  }
}
