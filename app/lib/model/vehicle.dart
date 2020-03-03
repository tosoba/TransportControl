import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  final String lat;
  final String lon;
  final String symbol;
  final String brigade;
  final String time;

  Vehicle({this.lat, this.lon, this.symbol, this.brigade, this.time});

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
