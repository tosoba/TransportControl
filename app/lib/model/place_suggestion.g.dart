// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSuggestion _$PlaceSuggestionFromJson(Map<String, dynamic> json) {
  return PlaceSuggestion(
    id: json['id'] as String,
    title: json['title'] as String,
    address: json['address'] == null
        ? null
        : Address.fromJson(json['address'] as Map<String, dynamic>),
    position: json['position'] == null
        ? null
        : LatLng.fromJson(json['position'] as Map<String, dynamic>),
    lastSearched: json['lastSearched'] == null
        ? null
        : DateTime.parse(json['lastSearched'] as String),
  );
}

Map<String, dynamic> _$PlaceSuggestionToJson(PlaceSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'address': instance.address,
      'position': instance.position,
      'lastSearched': instance.lastSearched?.toIso8601String(),
    };
