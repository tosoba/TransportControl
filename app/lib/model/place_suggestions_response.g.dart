// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_suggestions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSuggestionsResponse _$PlaceSuggestionsResponseFromJson(
    Map<String, dynamic> json) {
  return PlaceSuggestionsResponse(
    suggestions: (json['suggestions'] as List)
        ?.map((e) => e == null
            ? null
            : PlaceSuggestion.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$PlaceSuggestionsResponseToJson(
        PlaceSuggestionsResponse instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
    };
