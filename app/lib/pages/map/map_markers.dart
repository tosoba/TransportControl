import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:transport_control/model/vehicle.dart';

class ClusterableMarker extends Clusterable {
  final String number;
  final String symbol;
  final LatLng initialPosition;

  ClusterableMarker({
    @required String id,
    @required double lat,
    @required double lng,
    this.symbol,
    this.number,
    this.initialPosition,
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

  static ClusterableMarker fromVehicle(
    Vehicle vehicle, {
    @required LatLng initialPosition,
  }) {
    return ClusterableMarker(
      id: vehicle.number,
      lat: vehicle.lat,
      lng: vehicle.lon,
      number: vehicle.number,
      symbol: vehicle.symbol,
      initialPosition: initialPosition,
    );
  }
}

class IconifiedMarker {
  final BitmapDescriptor icon;
  final ClusterableMarker _marker;
  final List<ClusterableMarker> children;

  IconifiedMarker(this._marker, {@required this.icon, this.children});

  String get number => _marker.number;
  LatLng get position => LatLng(_marker.latitude, _marker.longitude);
  LatLng get initialPosition => _marker.initialPosition;

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

class MapVehicleMarker {
  final Marker marker;
  final String number;

  MapVehicleMarker({@required this.marker, @required this.number});
}
