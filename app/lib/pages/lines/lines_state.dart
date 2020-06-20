import 'package:flutter/material.dart';
import 'package:transport_control/model/line.dart';

class LinesState {
  final Map<Line, LineState> lines;
  final String symbolFilter;
  final LineListFilter listFilter;

  LinesState._({
    @required this.lines,
    @required this.symbolFilter,
    @required this.listFilter,
  });

  LinesState.initial()
      : lines = Map(),
        symbolFilter = null,
        listFilter = LineListFilter.all;

  LinesState copyWith({
    Map<Line, LineState> lines,
    String symbolFilter,
    LineListFilter listFilter,
  }) {
    return LinesState._(
      lines: lines ?? this.lines,
      symbolFilter: symbolFilter ?? this.symbolFilter,
      listFilter: listFilter ?? this.listFilter,
    );
  }

  Iterable<MapEntry<Line, LineState>> get selectedLines {
    return _filteredLines((entry) => entry.value.selected);
  }

  Iterable<MapEntry<Line, LineState>> get favouriteLines {
    return _filteredLines((entry) => entry.key.isFavourite);
  }

  Iterable<MapEntry<Line, LineState>> get trackedLines {
    return _filteredLines((entry) => entry.value.tracked);
  }

  List<MapEntry<Line, LineState>> get filteredLines {
    final symbolFilterPred = symbolFilterPredicate;
    final listFilterPred = listFilterPredicate;
    return lines.entries
        .where(
          (entry) => symbolFilterPred(entry) && listFilterPred(entry),
        )
        .toList();
  }

  Iterable<MapEntry<Line, LineState>> _filteredLines(
    bool Function(MapEntry<Line, LineState>) filter,
  ) {
    return lines.entries.where(filter);
  }

  bool Function(MapEntry<Line, LineState>) get symbolFilterPredicate {
    return symbolFilter == null || symbolFilter.isEmpty
        ? (MapEntry<Line, LineState> entry) => true
        : (MapEntry<Line, LineState> entry) => entry.key.symbol
            .toLowerCase()
            .contains(symbolFilter.trim().toLowerCase());
  }

  bool Function(MapEntry<Line, LineState>) get listFilterPredicate {
    switch (listFilter) {
      case LineListFilter.selected:
        return (entry) => entry.value.selected;
      case LineListFilter.tracked:
        return (entry) => entry.value.tracked;
      case LineListFilter.favourite:
        return (entry) => entry.key.isFavourite;
        break;
      case LineListFilter.all:
        return (_) => true;
      default:
        throw Error();
    }
  }
}

class LineState {
  final bool tracked;
  final bool selected;

  LineState({
    @required this.tracked,
    @required this.selected,
  });

  LineState.initial()
      : tracked = false,
        selected = false;

  LineState get untracked {
    return LineState(tracked: false, selected: selected);
  }

  LineState get toggleSelection {
    return LineState(
      tracked: tracked,
      selected: !selected,
    );
  }

  LineState get toggleTracked {
    return LineState(
      tracked: !tracked,
      selected: selected,
    );
  }

  LineState get toggleTrackedAndSelection {
    return LineState(
      tracked: !tracked,
      selected: !selected,
    );
  }
}

enum LineListFilter { selected, tracked, favourite, all }
