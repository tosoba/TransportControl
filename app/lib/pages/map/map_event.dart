import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/pages/map/vehicle_source.dart';

part "map_event.g.dart";

@superEnum
enum _MapEvent {
  @object
  ClearMap,

  @Data(fields: [DataField<Set<Line>>('lines')])
  TrackedLinesAdded,

  @UseClass(VehiclesAddedTemplate)
  VehiclesAdded,

  @object
  VehiclesAnimated,

  @Data(fields: [
    DataField<LatLngBounds>('bounds'),
    DataField<double>('zoom'),
  ])
  CameraMoved
}

class VehiclesAddedTemplate {
  VehiclesAddedTemplate(this.vehicles, this.source);

  final Iterable<Vehicle> vehicles;
  final VehicleSource source;
}
