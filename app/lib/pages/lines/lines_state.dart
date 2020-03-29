import 'package:flutter/material.dart';
import 'package:transport_control/model/line.dart';

class LinesState {
  final Map<Line, LineState> items;
  final String filter;

  LinesState({@required this.items, @required this.filter});

  factory LinesState.empty() => LinesState(items: Map(), filter: null);

  Set<Line> get selectedLines => items.entries
      .where((entry) => entry.value == LineState.SELECTED)
      .map((entry) => entry.key)
      .toSet();
}

enum LineState { IDLE, SELECTED, TRACKED }
