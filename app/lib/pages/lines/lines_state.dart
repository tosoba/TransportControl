part of 'package:transport_control/pages/lines/lines_bloc.dart';

class LinesState {
  final Map<Line, LineState> items;
  final String filter;

  LinesState({@required this.items, @required this.filter});

  factory LinesState.empty() => LinesState(items: Map(), filter: null);

  int get numberOfSelectedLines => items.values.fold(
        0,
        (counter, state) => state == LineState.SELECTED ? counter + 1 : counter,
      );
}

enum LineState { IDLE, SELECTED, TRACKED }
