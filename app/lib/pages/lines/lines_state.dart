part of 'package:transport_control/pages/lines/lines_bloc.dart';

class LinesState {
  final Map<Line, bool> items;
  final Map<Line, bool> filteredItems;

  LinesState({@required this.items, @required this.filteredItems});

  factory LinesState.empty() => LinesState(items: Map(), filteredItems: Map());
}
