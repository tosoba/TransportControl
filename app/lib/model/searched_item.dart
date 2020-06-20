import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';

part "searched_item.g.dart";

@superEnum
enum _SearchedItem {
  @Data(fields: [DataField<Line>('line')])
  LineItem,

  @Data(fields: [DataField<Location>('location')])
  LocationItem,
}
