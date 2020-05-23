import 'package:flutter/foundation.dart';
import 'package:transport_control/model/loadable.dart';
import 'package:transport_control/model/place_suggestion.dart';

class NearbyState {
  final String query;
  final Value<List<PlaceSuggestion>> suggestions;
  final List<PlaceSuggestion> recentlySearchedSuggestions;

  NearbyState._({
    @required this.query,
    @required this.suggestions,
    @required this.recentlySearchedSuggestions,
  });

  NearbyState.initial()
      : query = null,
        suggestions = Loadable.value(value: <PlaceSuggestion>[]),
        recentlySearchedSuggestions = [];

  NearbyState copyWith({
    String query,
    Value<List<PlaceSuggestion>> suggestions,
    List<PlaceSuggestion> recentlySearchedSuggestions,
  }) {
    return NearbyState._(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      recentlySearchedSuggestions:
          recentlySearchedSuggestions ?? this.recentlySearchedSuggestions,
    );
  }
}
