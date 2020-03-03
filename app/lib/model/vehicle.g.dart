// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return Vehicle(
    lat: json['lat'] as String,
    lon: json['lon'] as String,
    symbol: json['symbol'] as String,
    brigade: json['brigade'] as String,
    time: json['time'] as String,
  );
}

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'symbol': instance.symbol,
      'brigade': instance.brigade,
      'time': instance.time,
    };
