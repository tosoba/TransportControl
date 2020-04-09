import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/dao/favourite_lines_dao.dart';
import 'package:transport_control/db/dao/favourite_locations_dao.dart';
import 'package:transport_control/model/favourite_lines.dart';
import 'package:transport_control/model/favourite_locations.dart';

part 'database.g.dart';

@UseMoor(
  tables: [FavouriteLines, FavouriteLocations],
  daos: [FavouriteLinesDao, FavouriteLocationsDao],
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
