import 'package:super_enum/super_enum.dart';

part "map_selected_vehicle_update.g.dart";

@superEnum
enum _MapSelectedVehicleUpdate {
  @object
  NoChange,

  @object
  Deselect,

  @Data(fields: [DataField<String>('number')])
  Select,
}
