import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';

part "map_vehicle_source.g.dart";

@superEnum
enum _MapVehicleSource {
  @Data(fields: [DataField<Line>('line'), DataField<DateTime>('loadedAt')])
  OfLine,

  @Data(fields: [
    DataField<Location>('location'),
    DataField<DateTime>('loadedAt')
  ])
  NearbyLocation,

  @Data(fields: [
    DataField<LatLng>('position'),
    DataField<int>('radius'),
    DataField<DateTime>('loadedAt')
  ])
  NearbyUserLocation,

  @Data(fields: [
    DataField<LatLng>('position'),
    DataField<String>('title'),
    DataField<int>('radius'),
    DataField<DateTime>('loadedAt')
  ])
  NearbyPlace,
}
