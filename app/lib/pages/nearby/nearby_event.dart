import 'package:super_enum/super_enum.dart';

part "nearby_event.g.dart";

@superEnum
enum _NearbyEvent {
  @Data(fields: [DataField<String>('query')])
  QueryChanged,
}
