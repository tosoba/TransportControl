import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.placeSuggestions)
class PlaceSuggestions extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get address => text().nullable()();

  RealColumn get lat => real()();

  RealColumn get lng => real()();

  DateTimeColumn get lastSearched => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
