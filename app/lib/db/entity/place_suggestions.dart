import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.placeSuggestions)
class PlaceSuggestions extends Table {
  TextColumn get locationId => text()();

  TextColumn get label => text()();

  TextColumn get language => text().nullable()();

  TextColumn get countryCode => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get matchLevel => text().nullable()();

  DateTimeColumn get lastSearched => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {locationId};
}
