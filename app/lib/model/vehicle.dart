import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  @JsonKey(name: 'Lat')
  final double lat;
  @JsonKey(name: 'Lon')
  final double lon;
  @JsonKey(name: 'Lines')
  final String symbol;
  @JsonKey(name: 'Brigade')
  final String brigade;
  @JsonKey(name: 'Time')
  final DateTime lastUpdate;
  @JsonKey(name: 'VehicleNumber')
  final String number;

  Vehicle({
    this.lat,
    this.lon,
    this.symbol,
    this.brigade,
    this.lastUpdate,
    this.number,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
