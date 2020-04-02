import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';

part "vehicle_source.g.dart";

@superEnum
enum _VehicleSource {
  @Data(fields: [DataField<Line>('line')])
  AllOfLine,

  @Data(fields: [DataField<LatLngBounds>('bounds')])
  AllInBounds,

  // All nearby location?
}
