import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.placeSuggestionsResponse)
class PlaceSuggestionsResponses extends Table {
  TextColumn get query => text()();

  DateTimeColumn get lastSearched => dateTime()();

  TextColumn get json => text().nullable()();

  @override
  Set<Column> get primaryKey => {query};
}
