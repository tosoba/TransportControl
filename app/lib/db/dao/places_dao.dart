import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/db/entity/place_queries.dart';
import 'package:transport_control/db/entity/place_query_suggestions.dart';
import 'package:transport_control/db/entity/place_suggestions.dart';
import 'package:transport_control/util/model_util.dart';

part 'places_dao.g.dart';

@UseDao(tables: [PlaceQueries, PlaceSuggestions, PlaceQuerySuggestions])
@injectable
class PlacesDao extends DatabaseAccessor<Database> with _$PlacesDaoMixin {
  PlacesDao(Database db) : super(db);

  @factoryMethod
  static PlacesDao of(Database db) => db.placesDao;

  Future<void> insertSuggestionsForQuery({
    @required Iterable<PlaceSuggestion> suggestions,
    @required String query,
  }) {
    return transaction(() async {
      await into(placeQueries).insert(
        PlaceQuery(query: query),
        mode: InsertMode.insertOrReplace,
      );
      await db.batch(
        (batch) => batch.insertAll(
          placeSuggestions,
          suggestions
              .map(
                (suggestion) => PlaceSuggestionsCompanion.insert(
                  id: suggestion.id,
                  title: suggestion.title,
                  lat: suggestion.lat,
                  lng: suggestion.lng,
                  address: nullableValueFrom(suggestion.address),
                  lastSearched: nullableValueFrom(suggestion.lastSearched),
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        ),
      );
      await db.batch(
        (batch) => batch.insertAll(
          placeQuerySuggestions,
          suggestions
              .map(
                (suggestion) => PlaceQuerySuggestionsCompanion.insert(
                  query: query,
                  locationId: suggestion.id,
                ),
              )
              .toList(),
          mode: InsertMode.insertOrReplace,
        ),
      );
    });
  }

  Future<List<PlaceSuggestion>> selectSuggestionsByQuery(String query) async {
    final result =
        await (select(placeQueries)..where((q) => q.query.equals(query))).join([
      innerJoin(
        placeQuerySuggestions,
        placeQuerySuggestions.query.equalsExp(placeQueries.query),
      ),
      innerJoin(
        placeSuggestions,
        placeQuerySuggestions.locationId.equalsExp(placeSuggestions.id),
      ),
    ]).get();
    return result.map((row) => row.readTable(placeSuggestions)).toList();
  }

  Stream<List<PlaceSuggestion>> selectRecentlySearchedSuggestionsStream({
    @required int limit,
  }) {
    return (select(placeSuggestions)
          ..where((suggestion) => isNotNull(suggestion.lastSearched))
          ..orderBy([
            (suggestion) => OrderingTerm(
                  expression: suggestion.lastSearched,
                  mode: OrderingMode.desc,
                )
          ])
          ..limit(limit))
        .watch();
  }

  Future<int> updateLastSearchedByLocationId(String locationId) {
    return (update(placeSuggestions)
          ..where((suggestion) => suggestion.id.equals(locationId)))
        .write(PlaceSuggestionsCompanion(lastSearched: Value(DateTime.now())));
  }
}
