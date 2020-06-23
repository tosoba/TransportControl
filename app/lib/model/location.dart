import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/core.dart';
import 'package:transport_control/db/database.dart' as Db;

class Location {
  final int id;
  final String name;
  final LatLngBounds bounds;
  final bool isFavourite;
  final DateTime lastSearched;
  final int timesSearched;
  final DateTime savedAt;

  Location._(
    this.id,
    this.name,
    this.bounds,
    this.isFavourite,
    this.lastSearched,
    this.timesSearched,
    this.savedAt,
  );

  bool operator ==(other) {
    return other is Location &&
        id == other.id &&
        name == other.name &&
        bounds == other.bounds &&
        isFavourite == other.isFavourite &&
        lastSearched == other.lastSearched &&
        timesSearched == other.timesSearched &&
        savedAt == other.savedAt;
  }

  int get hashCode {
    return hashObjects([
      id.hashCode,
      name.hashCode,
      bounds.hashCode,
      isFavourite.hashCode,
      lastSearched.hashCode,
      timesSearched.hashCode,
      savedAt.hashCode,
    ]);
  }

  Location copyWith({
    String name,
    LatLngBounds bounds,
    bool isFavourite,
    DateTime lastSearched,
    int timesSearched,
    DateTime savedAt,
  }) {
    return Location._(
      id,
      name ?? this.name,
      bounds ?? this.bounds,
      isFavourite ?? this.isFavourite,
      lastSearched ?? this.lastSearched,
      timesSearched ?? this.timesSearched,
      savedAt ?? this.savedAt,
    );
  }

  Location.initial()
      : id = null,
        name = null,
        bounds = null,
        isFavourite = true,
        lastSearched = null,
        timesSearched = 0,
        savedAt = null;

  Location.fromDb(Db.Location location)
      : id = location.id,
        name = location.name,
        bounds = LatLngBounds(
          southwest: LatLng(
            location.southWestLat,
            location.southWestLng,
          ),
          northeast: LatLng(
            location.northEastLat,
            location.northEastLng,
          ),
        ),
        isFavourite = location.isFavourite,
        lastSearched = location.lastSearched,
        timesSearched = location.timesSearched,
        savedAt = location.savedAt;

  Db.Location get db {
    return Db.Location(
      id: id,
      name: name,
      southWestLat: bounds.southwest.latitude,
      southWestLng: bounds.southwest.longitude,
      northEastLat: bounds.northeast.latitude,
      northEastLng: bounds.northeast.longitude,
      isFavourite: isFavourite,
      lastSearched: lastSearched,
      timesSearched: timesSearched,
      savedAt: savedAt,
    );
  }
}
