import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/db/database.dart' as Db;
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
  final DateTime lastSearched;

  PlaceSuggestion({
    this.label,
    this.language,
    this.countryCode,
    this.locationId,
    this.address,
    this.matchLevel,
    this.lastSearched,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return _$PlaceSuggestionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PlaceSuggestionToJson(this);

  PlaceSuggestion.fromDb(Db.PlaceSuggestion suggestion)
      : label = suggestion.label,
        language = suggestion.language,
        countryCode = suggestion.countryCode,
        locationId = suggestion.locationId,
        address = suggestion.address == null
            ? null
            : Address.fromJson(
                jsonDecode(suggestion.address) as Map<String, dynamic>,
              ),
        matchLevel = suggestion.matchLevel,
        lastSearched = suggestion.lastSearched;

  Db.PlaceSuggestion get db {
    return Db.PlaceSuggestion(
      label: label,
      language: language,
      countryCode: countryCode,
      locationId: locationId,
      address: address == null ? null : jsonEncode(address.toJson()),
      matchLevel: matchLevel,
      lastSearched: lastSearched,
    );
  }
}
