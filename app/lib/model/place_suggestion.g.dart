// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSuggestion _$PlaceSuggestionFromJson(Map<String, dynamic> json) {
  return PlaceSuggestion(
    label: json['label'] as String,
    language: json['language'] as String,
    countryCode: json['countryCode'] as String,
    locationId: json['locationId'] as String,
    address: json['address'] == null
        ? null
        : Address.fromJson(json['address'] as Map<String, dynamic>),
    matchLevel: json['matchLevel'] as String,
  );
}

Map<String, dynamic> _$PlaceSuggestionToJson(PlaceSuggestion instance) =>
    <String, dynamic>{
      'label': instance.label,
      'language': instance.language,
      'countryCode': instance.countryCode,
      'locationId': instance.locationId,
      'address': instance.address,
      'matchLevel': instance.matchLevel,
    };
