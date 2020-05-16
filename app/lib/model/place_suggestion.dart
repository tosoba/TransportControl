import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/address.dart';

part 'place_suggestion.g.dart';

@JsonSerializable()
class PlaceSuggestion {
  final String label;
  final String language;
  final String countryCode;
  final String locationId;
  final Address address;
  final String matchLevel;

  PlaceSuggestion({
    this.label,
    this.language,
    this.countryCode,
    this.locationId,
    this.address,
    this.matchLevel,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return _$PlaceSuggestionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PlaceSuggestionToJson(this);
}
