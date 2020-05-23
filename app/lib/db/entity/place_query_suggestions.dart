import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.placeQuerySuggestions)
class PlaceQuerySuggestions extends Table {
  TextColumn get query => text()();

  TextColumn get locationId => text()();

  @override
  Set<Column> get primaryKey => {query, locationId};

  @override
  List<String> get customConstraints {
    return [
      'FOREIGN KEY (query) REFERENCES PlaceQueries(query) ON DELETE CASCADE',
      'FOREIGN KEY (location_id) REFERENCES PlaceSuggestions(location_id) ON DELETE CASCADE'
    ];
  }
}
