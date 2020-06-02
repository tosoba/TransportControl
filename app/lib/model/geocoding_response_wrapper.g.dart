// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoding_response_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodingResponseWrapper _$GeocodingResponseWrapperFromJson(
    Map<String, dynamic> json) {
  return GeocodingResponseWrapper(
    response: json['response'] == null
        ? null
        : GeocodingResponse.fromJson(json['response'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GeocodingResponseWrapperToJson(
        GeocodingResponseWrapper instance) =>
    <String, dynamic>{
      'response': instance.response,
    };
