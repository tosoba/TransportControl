import 'package:super_enum/super_enum.dart';
import 'package:transport_control/db/database.dart';

part "searched_entity.g.dart";

@superEnum
enum _SearchedEntity {
  @Data(fields: [DataField<Line>('line')])
  LineEntity,

  @Data(fields: [DataField<Location>('location')])
  LocationEntity,
}
