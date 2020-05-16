import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/db/entity/place_suggestions.dart';

part 'place_suggestions_dao.g.dart';

@UseDao(tables: [PlaceSuggestions])
@injectable
class PlaceSuggestionsDao extends DatabaseAccessor<Database>
    with _$PlaceSuggestionsDaoMixin {
  PlaceSuggestionsDao(Database db) : super(db);

  @factoryMethod
  static PlaceSuggestionsDao of(Database db) => db.placeSuggestionsDao;

  Future insertSuggestion(PlaceSuggestion suggestion) {
    return into(placeSuggestions).insert(suggestion);
  }

  Future<PlaceSuggestion> selectByQuery(String query) {
    return (select(placeSuggestions)
          ..where((suggestion) => suggestion.query.equals(query)))
        .getSingle();
  }

  Future<int> updateResponseByQuery({
    @required String query,
    @required String response,
  }) {
    return (update(placeSuggestions)
          ..where((suggestion) => suggestion.query.equals(query)))
        .write(PlaceSuggestionsCompanion(response: Value(response)));
  }

  Stream<List<PlaceSuggestion>> selectSuggestionsStream({int limit = 10}) {
    return (select(placeSuggestions)..limit(limit)).watch();
  }
}
