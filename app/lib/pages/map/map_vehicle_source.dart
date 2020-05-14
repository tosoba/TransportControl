import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';

part "map_vehicle_source.g.dart";

@superEnum
enum _MapVehicleSource {
  @Data(fields: [DataField<Line>('line'), DataField<DateTime>('loadedAt')])
  OfLine,

  @Data(fields: [
    DataField<LatLngBounds>('bounds'),
    DataField<DateTime>('loadedAt')
  ])
  InBounds,

  @Data(fields: [
    DataField<LatLng>('position'),
    DataField<double>('radius'),
    DataField<DateTime>('loadedAt')
  ])
  Nearby,
}
