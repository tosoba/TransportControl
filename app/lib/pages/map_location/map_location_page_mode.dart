import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/location.dart';

part "map_location_page_mode.g.dart";

@superEnum
enum _MapLocationPageMode {
  @object
  Add,

  @Data(fields: [DataField<Location>('location')])
  Existing,
}
