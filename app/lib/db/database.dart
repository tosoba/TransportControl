import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/dao/lines_dao.dart';
import 'package:transport_control/db/dao/locations_dao.dart';
import 'package:transport_control/db/dao/places_dao.dart';
import 'package:transport_control/db/entity/lines.dart';
import 'package:transport_control/db/entity/locations.dart';
import 'package:transport_control/db/entity/place_queries.dart';
import 'package:transport_control/db/entity/place_query_suggestions.dart';
import 'package:transport_control/db/entity/place_suggestions.dart';

part 'database.g.dart';

@UseMoor(
  tables: [
    Lines,
    Locations,
    PlaceQueries,
    PlaceSuggestions,
    PlaceQuerySuggestions
  ],
  daos: [LinesDao, LocationsDao, PlacesDao],
)
@singleton
class Database extends _$Database {
  Database()
      : super(
          FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite',
            logStatements: true,
          ),
        );

  @override
  int get schemaVersion => 1;
}
