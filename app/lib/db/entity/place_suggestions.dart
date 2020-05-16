import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.placeSuggestions)
class PlaceSuggestions extends Table {
  TextColumn get query => text()();

  DateTimeColumn get lastSearched => dateTime()();

  TextColumn get response => text().nullable()();

  @override
  Set<Column> get primaryKey => {query};
}
