import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class ClusterableMarker extends Clusterable {
  final String number;
  final String symbol;
  final LatLng previousPosition;

  ClusterableMarker({
    @required String id,
    @required double lat,
    @required double lng,
    this.symbol,
    this.number,
    this.previousPosition,
    bool isCluster = false,
    int clusterId,
    int pointsSize,
    String childMarkerId,
  }) : super(
          markerId: id,
          latitude: lat,
          longitude: lng,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );
}

class IconifiedMarker {
  final BitmapDescriptor icon;
  final ClusterableMarker _marker;
  final List<LatLng> childrenPositions;

  IconifiedMarker(
    this._marker, {
    @required this.icon,
    this.childrenPositions,
  });

  String get number => _marker.number;
  LatLng get position => LatLng(_marker.latitude, _marker.longitude);
  bool get isCluster => _marker.isCluster;
  LatLng get previousPosition => _marker.previousPosition;

  Marker toGoogleMapMarker({void Function() onTap}) {
    return Marker(
      markerId: MarkerId(
        _marker.isCluster ? 'cl_${_marker.markerId}' : _marker.markerId,
      ),
      position: LatLng(_marker.latitude, _marker.longitude),
      icon: icon,
      onTap: onTap,
    );
  }

  Marker googleMapMarker({LatLng position, void Function() onTap}) {
    return Marker(
      markerId: MarkerId(
        _marker.isCluster ? 'cl_${_marker.markerId}' : _marker.markerId,
      ),
      position: position ?? LatLng(_marker.latitude, _marker.longitude),
      icon: icon,
      onTap: onTap,
    );
  }
}
