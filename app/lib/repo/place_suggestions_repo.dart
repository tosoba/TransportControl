import 'package:flutter/foundation.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/model/result.dart';

abstract class PlaceSuggestionsRepo {
  Future<Result<List<PlaceSuggestion>>> getSuggestions({@required String query});

  Stream<List<String>> getLatestQueries({@required int limit});
}
