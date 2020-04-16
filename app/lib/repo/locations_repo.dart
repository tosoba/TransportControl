import 'package:transport_control/model/location.dart';

abstract class LocationsRepo {
  Stream<List<Location>> get favouriteLocationsStream;
}
