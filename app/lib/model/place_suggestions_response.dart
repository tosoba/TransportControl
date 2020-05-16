import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/place_suggestion.dart';

part 'place_suggestions_response.g.dart';

@JsonSerializable()
class PlaceSuggestionsResponse {
  final List<PlaceSuggestion> suggestions;

  PlaceSuggestionsResponse({this.suggestions});

  factory PlaceSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return _$PlaceSuggestionsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PlaceSuggestionsResponseToJson(this);
}
