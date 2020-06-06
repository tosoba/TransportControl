import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/db/database.dart' as Db;
import 'package:transport_control/model/address.dart';

part 'place_suggestion.g.dart';

@JsonSerializable()
class PlaceSuggestion {
  final String id;
  final String title;
  final Address address;
  final DateTime lastSearched;

  PlaceSuggestion({
    this.id,
    this.title,
    this.address,
    this.lastSearched,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return _$PlaceSuggestionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PlaceSuggestionToJson(this);

  PlaceSuggestion.fromDb(Db.PlaceSuggestion suggestion)
      : id = suggestion.id,
        title = suggestion.title,
        address = suggestion.address == null
            ? null
            : Address.fromJson(
                jsonDecode(suggestion.address) as Map<String, dynamic>,
              ),
        lastSearched = suggestion.lastSearched;

  Db.PlaceSuggestion get db {
    return Db.PlaceSuggestion(
      id: id,
      title: title,
      address: address == null ? null : jsonEncode(address.toJson()),
      lastSearched: lastSearched,
    );
  }
}
