part of 'package:transport_control/pages/lines/lines_bloc.dart';

class LinesState {
  final Map<Line, bool> items;
  final String filter;

  LinesState({@required this.items, @required this.filter});

  factory LinesState.empty() => LinesState(items: Map(), filter: null);
}
