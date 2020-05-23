import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/db/entity/place_suggestions_responses.dart';
import 'package:transport_control/model/place_query.dart';

part 'place_suggestions_responses_dao.g.dart';

@UseDao(tables: [PlaceSuggestionsResponses])
@injectable
class PlaceSuggestionsResponsesDao extends DatabaseAccessor<Database>
    with _$PlaceSuggestionsResponsesDaoMixin {
  PlaceSuggestionsResponsesDao(Database db) : super(db);

  @factoryMethod
  static PlaceSuggestionsResponsesDao of(Database db) {
    return db.placeSuggestionsResponsesDao;
  }

  Future insertResponse(PlaceSuggestionsResponse response) {
    return into(placeSuggestionsResponses).insert(response);
  }

  Future<PlaceSuggestionsResponse> selectByQuery(String query) {
    return (select(placeSuggestionsResponses)
          ..where((suggestion) => suggestion.query.equals(query)))
        .getSingle();
  }

  Future<int> updateByQuery({@required String query, @required String json}) {
    return (update(placeSuggestionsResponses)
          ..where((suggestion) => suggestion.query.equals(query)))
        .write(PlaceSuggestionsResponsesCompanion(json: Value(json)));
  }

  Stream<List<PlaceQuery>> selectLatestQueriesStream({@required int limit}) {
    return (select(placeSuggestionsResponses)
          ..orderBy(
            [(response) => OrderingTerm(expression: response.lastSearched)],
          )
          ..limit(limit))
        .watch()
        .map(
          (responsesList) => responsesList
              .map(
                (response) => PlaceQuery(
                  text: response.query,
                  lastSearched: response.lastSearched,
                ),
              )
              .toList(),
        );
  }

  Future<int> deleteLastSearchedBefore({@required DateTime timestampLimit}) {
    return (delete(placeSuggestionsResponses)
          ..where(
            (response) {
              return response.lastSearched.isSmallerThanValue(timestampLimit);
            },
          ))
        .go();
  }
}
