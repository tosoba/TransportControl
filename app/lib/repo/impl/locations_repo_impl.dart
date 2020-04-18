import 'package:injectable/injectable.dart';
import 'package:transport_control/db/dao/locations_dao.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/repo/locations_repo.dart';

@RegisterAs(LocationsRepo, env: Env.dev)
@singleton
class LocationsRepoImpl extends LocationsRepo {
  final LocationsDao _dao;

  LocationsRepoImpl(this._dao);

  @override
  Stream<List<Location>> get favouriteLocationsStream {
    return _dao.selectFavouriteLocationsStream.map((locationList) =>
        locationList.map((location) => Location.fromDb(location)).toList());
  }

  @override
  Future<int> insertLocation(Location location) {
    return _dao.insertLocation(location.db);
  }

  @override
  Future<int> updateLocation(Location location) {
    return _dao.updateLocation(location.db);
  }
}
