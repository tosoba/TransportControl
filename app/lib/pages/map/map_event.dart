import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/vehicle.dart';

part "map_event.g.dart";

@superEnum
enum _MapEvent {
  @object
  ClearMap,

  @Data(fields: [DataField<Set<Line>>('lines')])
  TrackedLinesAdded,

  @Data(fields: [DataField<Iterable<Vehicle>>('vehicles')])
  VehiclesAdded,

  @Data(fields: [
    DataField<Iterable<Vehicle>>('vehicles'),
    DataField<Set<Line>>('lines')
  ])
  VehiclesOfLinesAdded,

  @object
  VehiclesAnimated,

  @Data(fields: [
    DataField<LatLngBounds>('bounds'),
    DataField<double>('zoom'),
  ])
  CameraMoved
}
