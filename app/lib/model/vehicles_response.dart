import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/vehicle.dart';

part 'vehicles_response.g.dart';

@JsonSerializable()
class VehiclesResponse {
  @JsonKey(name: 'result')
  final List<Vehicle> vehicles;

  VehiclesResponse({this.vehicles});

  factory VehiclesResponse.fromJson(Map<String, dynamic> json) => _$VehiclesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VehiclesResponseToJson(this);
}
