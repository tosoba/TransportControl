import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/lat_lng.dart';
import 'package:transport_control/model/map_view.dart';

part 'geocoded_location.g.dart';

@JsonSerializable()
class GeocodedLocation {
  @JsonKey(name: 'LocationId')
  final String locationId;
  @JsonKey(name: 'LocationType')
  final String locationType;
  @JsonKey(name: 'DisplayPosition')
  final LatLng displayPosition;
  @JsonKey(name: 'MapView')
  final MapView mapView;

  GeocodedLocation({
    this.locationId,
    this.locationType,
    this.displayPosition,
    this.mapView,
  });

  factory GeocodedLocation.fromJson(Map<String, dynamic> json) {
    return _$GeocodedLocationFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GeocodedLocationToJson(this);
}
