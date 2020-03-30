import 'package:flutter/material.dart';
import 'package:transport_control/model/line.dart';

class LinesState {
  final Map<Line, LineState> items;
  final String symbolFilter;
  final LineListFilter listFilter;

  LinesState({
    @required this.items,
    @required this.symbolFilter,
    @required this.listFilter,
  });

  LinesState.empty()
      : items = Map(),
        symbolFilter = null,
        listFilter = LineListFilter.ALL;

  LinesState copyWith({
    Map<Line, LineState> items,
    String symbolFilter,
    LineListFilter listFilter,
  }) {
    return LinesState(
      items: items ?? this.items,
      symbolFilter: symbolFilter ?? this.symbolFilter,
      listFilter: listFilter ?? this.listFilter,
    );
  }

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

enum LineListFilter { SELECTED, TRACKED, FAVOURITE, ALL }
