// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return Vehicle(
    lat: (json['Lat'] as num)?.toDouble(),
    lon: (json['Lon'] as num)?.toDouble(),
    symbol: json['Lines'] as String,
    brigade: json['Brigade'] as String,
    lastUpdate:
        json['Time'] == null ? null : DateTime.parse(json['Time'] as String),
    number: json['VehicleNumber'] as String,
  );
}

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'Lat': instance.lat,
      'Lon': instance.lon,
      'Lines': instance.symbol,
      'Brigade': instance.brigade,
      'Time': instance.lastUpdate?.toIso8601String(),
      'VehicleNumber': instance.number,
    };
