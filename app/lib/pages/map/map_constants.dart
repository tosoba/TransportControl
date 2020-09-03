import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConstants {
  static const double initialZoom = 11;
  static final LatLng initialTarget = LatLng(52.237049, 21.017532);

  static const int minClusterZoom = 0;
  static const int maxClusterZoom = 19;

  static const double minAnimationZoom = 12;

  static const double minLocationPageMapZoom = 0;
  static const double maxLocationPageMapZoom = 17;

  static const int markerWidth = 60;
  static const int markerHeight = 80;

  MapConstants._();
}
