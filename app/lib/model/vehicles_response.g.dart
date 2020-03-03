// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehiclesResponse _$VehiclesResponseFromJson(Map<String, dynamic> json) {
  return VehiclesResponse(
    vehicles: (json['vehicles'] as List)
        ?.map((e) =>
            e == null ? null : Vehicle.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$VehiclesResponseToJson(VehiclesResponse instance) =>
    <String, dynamic>{
      'vehicles': instance.vehicles,
    };
