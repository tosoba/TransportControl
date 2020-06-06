import 'package:json_annotation/json_annotation.dart';

part 'lat_lng.g.dart';

@JsonSerializable()
class LatLng {
  final double lat;
  final double lng;

  LatLng({this.lat, this.lng});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return _$LatLngFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LatLngToJson(this);
}
