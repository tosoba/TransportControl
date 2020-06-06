import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/db/database.dart' as Db;
import 'package:transport_control/model/address.dart';
import 'package:transport_control/model/lat_lng.dart';

part 'place_suggestion.g.dart';

@JsonSerializable()
class PlaceSuggestion {
  final String id;
  final String title;
  final Address address;
  final LatLng position;
  final DateTime lastSearched;

  PlaceSuggestion({
    this.id,
    this.title,
    this.address,
    this.position,
    this.lastSearched,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return _$PlaceSuggestionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PlaceSuggestionToJson(this);

  PlaceSuggestion.fromDb(Db.PlaceSuggestion suggestion)
      : id = suggestion.id,
        title = suggestion.title,
        position = LatLng(lat: suggestion.lat, lng: suggestion.lng),
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
      lat: position.lat,
      lng: position.lng,
      address: address == null ? null : jsonEncode(address.toJson()),
      lastSearched: lastSearched,
    );
  }
}
