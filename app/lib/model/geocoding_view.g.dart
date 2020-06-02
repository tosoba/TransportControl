// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoding_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodingView _$GeocodingViewFromJson(Map<String, dynamic> json) {
  return GeocodingView(
    results: (json['Result'] as List)
        ?.map((e) => e == null
            ? null
            : GeocodingResult.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$GeocodingViewToJson(GeocodingView instance) =>
    <String, dynamic>{
      'Result': instance.results,
    };
