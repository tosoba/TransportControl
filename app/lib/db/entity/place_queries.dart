import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.placeQueries)
class PlaceQueries extends Table {
  TextColumn get query => text()();

  @override
  Set<Column> get primaryKey => {query};
}
