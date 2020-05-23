import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';

part "map_event.g.dart";

@superEnum
enum _MapEvent {
  @object
  ClearMap,

  @Data(fields: [DataField<Iterable<Vehicle>>('vehicles')])
  UpdateVehicles,

  @Data(fields: [
    DataField<Iterable<Vehicle>>('vehicles'),
    DataField<Set<Line>>('lines')
  ])
  AddVehiclesOfLines,

  @Data(fields: [
    DataField<Iterable<Vehicle>>('vehicles'),
    DataField<LatLngBounds>('bounds')
  ])
  AddVehiclesInBounds,

  @Data(fields: [
    DataField<Iterable<Vehicle>>('vehicles'),
    DataField<LatLng>('position'),
    DataField<double>('radius'),
  ])
  AddVehiclesNearby,

  @object
  AnimateVehicles,

  @Data(fields: [
    DataField<LatLngBounds>('bounds'),
    DataField<double>('zoom'),
  ])
  CameraMoved,

  @Data(fields: [DataField<Set<Line>>('lines')])
  TrackedLinesRemoved,

  @Data(fields: [DataField<String>('number')])
  SelectVehicle,

  @object
  DeselectVehicle,

  @Data(fields: [DataField<MapVehicleSource>('source')])
  RemoveSource,
}
