// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoding_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodingResult _$GeocodingResultFromJson(Map<String, dynamic> json) {
  return GeocodingResult(
    location: json['Location'] == null
        ? null
        : GeocodedLocation.fromJson(json['Location'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GeocodingResultToJson(GeocodingResult instance) =>
    <String, dynamic>{
      'Location': instance.location,
    };
