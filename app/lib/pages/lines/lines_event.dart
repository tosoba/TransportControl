import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_state.dart';

part "lines_event.g.dart";

@superEnum
enum _LinesEvent {
  @Data(fields: [DataField<Map<Line, LineState>>('lines')])
  UpdateLines,

  @Data(fields: [DataField<String>('filter')])
  SymbolFilterChanged,

  @Data(fields: [DataField<LineListFilter>('filter')])
  ListFilterChanged,

  @Data(fields: [DataField<Line>('line')])
  ToggleLineSelection,

  @Data(fields: [DataField<Line>('line')])
  ToggleLineTracking,

  @object
  ResetSelection,

  @Data(fields: [DataField<bool>('resetSelection')])
  TrackSelectedLines,

  @Data(fields: [DataField<Set<Line>>('lines')])
  ToggleLinesTracking,

  @Data(fields: [DataField<bool>('resetSelection')])
  UntrackSelectedLines,

  @object
  UntrackAllLines,
}
