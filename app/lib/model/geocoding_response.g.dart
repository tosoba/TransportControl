// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoding_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodingResponse _$GeocodingResponseFromJson(Map<String, dynamic> json) {
  return GeocodingResponse(
    views: (json['views'] as List)
        ?.map((e) => e == null
            ? null
            : GeocodingView.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$GeocodingResponseToJson(GeocodingResponse instance) =>
    <String, dynamic>{
      'views': instance.views,
    };
