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

  @object
  VehiclesAnimated
}
