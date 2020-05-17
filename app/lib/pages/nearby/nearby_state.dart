import 'package:flutter/foundation.dart';
import 'package:transport_control/model/place_suggestion.dart';

class NearbyState {
  final String query;
  final List<PlaceSuggestion> suggestions;
  final List<String> latestQueries;

  NearbyState._({
    @required this.query,
    @required this.suggestions,
    @required this.latestQueries,
  });

  NearbyState.initial()
      : query = null,
        suggestions = [],
        latestQueries = [];

  NearbyState copyWith({
    String query,
    List<PlaceSuggestion> suggestions,
    List<String> latestQueries,
  }) {
    return NearbyState._(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      latestQueries: latestQueries ?? this.latestQueries,
    );
  }
}
