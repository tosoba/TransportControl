import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/db/database.dart' as Db;

class Location {
  final int id;
  final String name;
  final LatLngBounds bounds;
  final bool isFavourite;
  final DateTime lastSearched;
  final int timesSearched;

  Location(
    this.id,
    this.name,
    this.bounds,
    this.isFavourite,
    this.lastSearched,
    this.timesSearched,
  );

  Location.fromDb(Db.Location line)
      : id = line.id,
        name = line.name,
        bounds = LatLngBounds(
          southwest: LatLng(
            line.southWestLat,
            line.southWestLng,
          ),
          northeast: LatLng(
            line.northEastLat,
            line.northEastLng,
          ),
        ),
        isFavourite = line.isFavourite,
        lastSearched = line.lastSearched,
        timesSearched = line.timesSearched;
}
