import 'package:injectable/injectable.dart';
import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/database.dart';
import 'package:transport_control/db/entity/locations.dart';

part 'locations_dao.g.dart';

@UseDao(tables: [Locations])
@injectable
class LocationsDao extends DatabaseAccessor<Database> with _$LocationsDaoMixin {
  LocationsDao(Database db) : super(db);

  @factoryMethod
  static LocationsDao of(Database db) => db.locationsDao;

  Future<int> insertLocation(Location location) {
    return into(locations).insert(location);
  }

  Stream<List<Location>> selectFavouriteLocationsStream() {
    return select(locations).watch();
  }
}
