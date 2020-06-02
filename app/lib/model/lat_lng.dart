import 'package:json_annotation/json_annotation.dart';

part 'lat_lng.g.dart';

@JsonSerializable()
class LatLng {
  @JsonKey(name: 'Latitude')
  final double latitude;
  @JsonKey(name: 'Longitude')
  final double longitude;

  LatLng({this.latitude, this.longitude});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return _$LatLngFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LatLngToJson(this);
}
