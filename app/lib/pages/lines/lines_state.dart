import 'package:flutter/material.dart';
import 'package:transport_control/model/line.dart';

class LinesState {
  final Map<Line, LineState> items;
  final String filter;

  LinesState({@required this.items, @required this.filter});

  factory LinesState.empty() => LinesState(items: Map(), filter: null);

  Set<Line> get selectedLines => items.entries
      .where((entry) => entry.value.selected)
      .map((entry) => entry.key)
      .toSet();
}

class LineState {
  final bool favourite;
  final bool tracked;
  final bool selected;

  LineState({
    @required this.favourite,
    @required this.tracked,
    @required this.selected,
  });

  LineState.initial()
      : favourite = false,
        tracked = false,
        selected = false;

  LineState get toggleSelection {
    return LineState(
      favourite: favourite,
      tracked: tracked,
      selected: !selected,
    );
  }

  LineState get toggleTracked {
    return LineState(
      favourite: favourite,
      tracked: !tracked,
      selected: selected,
    );
  }
}
