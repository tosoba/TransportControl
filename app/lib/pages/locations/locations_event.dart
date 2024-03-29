import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_list_order.dart';

part "locations_event.g.dart";

@superEnum
enum _LocationsEvent {
  @Data(fields: [DataField<List<Location>>('locations')])
  UpdateLocations,

  @Data(fields: [DataField<String>('filter')])
  NameFilterChanged,

  @Data(fields: [DataField<LocationsListOrder>('order')])
  ChangeListOrder,
}
