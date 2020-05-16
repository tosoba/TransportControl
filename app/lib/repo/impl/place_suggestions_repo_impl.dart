import 'dart:convert';

import 'package:transport_control/api/places_api.dart';
import 'package:transport_control/db/dao/place_suggestions_responses_dao.dart';
import 'package:transport_control/db/database.dart' as db;
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/model/place_suggestions_response.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/repo/place_suggestions_repo.dart';

class PlaceSuggestionsRepoImpl implements PlaceSuggestionsRepo {
  final PlaceSuggestionsResponsesDao _dao;
  final PlacesApi _api;

  PlaceSuggestionsRepoImpl(this._dao, this._api);

  static const Duration _timeoutDuration = const Duration(seconds: 3);

  @override
  Stream<List<String>> getLatestQueries({int limit}) {
    return _dao.selectLatestQueriesStream(limit: limit);
  }

  @override
  Future<Result<List<PlaceSuggestion>>> getSuggestions({String query}) async {
    final cachedResponse = await _dao.selectByQuery(query);
    if (cachedResponse != null && cachedResponse.json != null) {
      final json = jsonDecode(cachedResponse.json) as Map<String, dynamic>;
      return Result.success(
        data: PlaceSuggestionsResponse.fromJson(json).suggestions,
      );
    } else if (cachedResponse == null) {
      _dao.insertResponse(
        db.PlaceSuggestionsResponse(query: query, lastSearched: DateTime.now()),
      );
    }

    try {
      final response =
          await _api.fetchSuggestions(query: query).timeout(_timeoutDuration);
      _dao.updateByQuery(query: query, json: jsonEncode(response.toJson()));
      return Result.success(data: response.suggestions);
    } catch (error) {
      return Result<List<PlaceSuggestion>>.failure(error: error);
    }
  }
}
