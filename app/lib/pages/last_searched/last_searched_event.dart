import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/searched_item.dart';

part "last_searched_event.g.dart";

@superEnum
enum _LastSearchedEvent {
  @Data(fields: [DataField<List<SearchedItem>>('items')])
  UpdateItems,
}
