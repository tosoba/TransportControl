import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/db/database.dart' as Db;

class Location {
  final int id;
  final String name;
  final LatLngBounds bounds;
  final bool isFavourite;
  final DateTime lastSearched;
  final int timesSearched;

  Location._(
    this.id,
    this.name,
    this.bounds,
    this.isFavourite,
    this.lastSearched,
    this.timesSearched,
  );

  Location copyWith({
    String name,
    LatLngBounds bounds,
    bool isFavourite,
    DateTime lastSearched,
    int timesSearched,
  }) {
    return Location._(
      id,
      name ?? this.name,
      bounds ?? this.bounds,
      isFavourite ?? this.isFavourite,
      lastSearched ?? this.lastSearched,
      timesSearched ?? this.timesSearched,
    );
  }

  Location.initial()
      : id = null,
        name = null,
        bounds = null,
        isFavourite = false,
        lastSearched = null,
        timesSearched = 0;

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
