import 'package:super_enum/super_enum.dart';

part "searched_item_identifier.g.dart";

@superEnum
enum _SearchedItemIdentifier {
  @Data(fields: [DataField<String>('symbol')])
  Line,

  @Data(fields: [DataField<int>('id')])
  Location,
}
