import 'package:moor_flutter/moor_flutter.dart';
import 'package:transport_control/db/tables.dart';

@DataClassName(Tables.locations)
class Locations extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get name => text()();

  RealColumn get southWestLat => real().nullable()();

  RealColumn get southWestLng => real().nullable()();

  RealColumn get northEastLat => real().nullable()();

  RealColumn get northEastLng => real().nullable()();

  RealColumn get positionLat => real().nullable()();

  RealColumn get positionLng => real().nullable()();

  RealColumn get radiusInMeters => real().nullable()();

  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastSearched => dateTime().nullable()();

  IntColumn get timesSearched => integer().withDefault(const Constant(1))();

  DateTimeColumn get savedAt => dateTime()();

  @override
  List<String> get customConstraints => [
        '''CHECK (southWestLat IS NULL AND southWestLng IS NULL 
    AND northEastLat IS NULL AND northEastLng is NULL 
    AND positionLat IS NOT NULL AND positionLng IS NOT NULL AND radiusInMeters IS NOT NULL) 
    OR 
    (southWestLat IS NOT NULL AND southWestLng IS NOT NULL 
    AND northEastLat IS NOT NULL AND northEastLng is NOT NULL 
    AND positionLat IS NULL AND positionLng IS NULL AND radiusInMeters IS NULL)''',
      ];
}
