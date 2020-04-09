import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/model/favourite_locations.dart';

part 'favourite_locations_dao.g.dart';

@UseDao(tables: [FavouriteLocations])
class FavouriteLocationsDao extends DatabaseAccessor<Database>
    with _$FavouriteLocationsDaoMixin {
  FavouriteLocationsDao(Database db) : super(db);

  Future<int> insertLocation(FavouriteLocation location) {
    return into(favouriteLocations).insert(location);
  }

  Stream<List<FavouriteLocation>> favouriteLocationsStream() {
    return select(favouriteLocations).watch();
  }
}
