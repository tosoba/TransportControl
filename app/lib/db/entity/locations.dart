import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.locations)
class Locations extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  RealColumn get southWestLat => real()();

  RealColumn get southWestLng => real()();

  RealColumn get northEastLat => real()();

  RealColumn get northEastLng => real()();

  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastSearched => dateTime()();

  IntColumn get timesSearched => integer().withDefault(const Constant(1))();
}
