import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_state.dart';

part "lines_event.g.dart";

@superEnum
enum _LinesEvent {
  @Data(fields: [DataField<Map<Line, LineState>>('items')])
  Created,

  @Data(fields: [DataField<String>('filter')])
  FilterChanged,

  @Data(fields: [DataField<Line>('item')])
  ItemSelectionChanged,

  @object
  SelectionReset,

  @Data(fields: [DataField<Iterable<Line>>('lines')])
  TrackedLinesChanged,
}
