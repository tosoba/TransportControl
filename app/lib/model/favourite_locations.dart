import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.favouriteLocation)
class FavouriteLocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get southWestLat => real()();
  RealColumn get southWestLng => real()();
  RealColumn get northEastLat => real()();
  RealColumn get northEastLng => real()();
}
