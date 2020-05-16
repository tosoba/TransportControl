import 'package:transport_control/model/location.dart';

abstract class LocationsRepo {
  Stream<List<Location>> get favouriteLocationsStream;

  Future<int> insertLocation(Location location);

  Future<int> updateLocation(Location location);

  Future<int> deleteLocation(Location location);
}
