part of 'package:transport_control/pages/lines/lines_bloc.dart';

class LineListItemState {
  final Line line;
  final bool selected = false;

  LineListItemState(this.line);
}

class LinesState {
  final List<LineListItemState> items;
  final List<LineListItemState> filteredItems;

  LinesState({@required this.items, @required this.filteredItems});

  factory LinesState.empty() =>
      LinesState(items: List(), filteredItems: List());
}
