import 'package:injectable/injectable.dart';
import 'package:transport_control/api/places_api.dart';
import 'package:transport_control/db/dao/places_dao.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/place_suggestion.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/repo/place_suggestions_repo.dart';

@RegisterAs(PlaceSuggestionsRepo, env: Env.dev)
@singleton
class PlaceSuggestionsRepoImpl implements PlaceSuggestionsRepo {
  final PlacesDao _dao;
  final PlacesApi _api;

  PlaceSuggestionsRepoImpl(this._dao, this._api);

  static const Duration _timeoutDuration = const Duration(seconds: 3);

  @override
  Stream<List<PlaceSuggestion>> getRecentlySearchedSuggestions({int limit}) {
    return _dao.selectRecentlySearchedSuggestionsStream(limit: limit).map(
          (suggestions) => suggestions
              .map((suggestion) => PlaceSuggestion.fromDb(suggestion))
              .toList(),
        );
  }

  @override
  Future<Result<List<PlaceSuggestion>>> getSuggestions({String query}) async {
    final savedSuggestions = await _dao.selectSuggestionsByQuery(query);
    if (savedSuggestions != null && savedSuggestions.isNotEmpty) {
      return Result.success(
        data: savedSuggestions
            .map((suggestion) => PlaceSuggestion.fromDb(suggestion))
            .toList(),
      );
    }

    try {
      final response =
          await _api.fetchSuggestions(query: query).timeout(_timeoutDuration);
      final filteredSuggestions = response.suggestions.where(
        (suggestion) =>
            suggestion.title != null &&
            suggestion.position?.lat != null &&
            suggestion.position?.lng != null,
      );
      _dao.insertSuggestionsForQuery(
        query: query,
        suggestions: filteredSuggestions.map((suggestion) => suggestion.db),
      );
      return Result.success(data: filteredSuggestions.toList());
    } catch (error) {
      return Result<List<PlaceSuggestion>>.failure(error: error);
    }
  }

  @override
  Future<int> updateLastSearchedBy({String locationId}) {
    return _dao.updateLastSearchedByLocationId(locationId);
  }
}
