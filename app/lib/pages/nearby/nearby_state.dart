import 'package:flutter/foundation.dart';
import 'package:transport_control/model/loadable.dart';
import 'package:transport_control/model/place_query.dart';
import 'package:transport_control/model/place_suggestion.dart';

class NearbyState {
  final String query;
  final Value<List<PlaceSuggestion>> suggestions;
  final List<PlaceQuery> latestQueries;

  NearbyState._({
    @required this.query,
    @required this.suggestions,
    @required this.latestQueries,
  });

  NearbyState.initial()
      : query = null,
        suggestions = Loadable.value(value: <PlaceSuggestion>[]),
        latestQueries = [];

  NearbyState copyWith({
    String query,
    Value<List<PlaceSuggestion>> suggestions,
    List<PlaceQuery> latestQueries,
  }) {
    return NearbyState._(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      latestQueries: latestQueries ?? this.latestQueries,
    );
  }
}
