import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_event.dart';
import 'package:transport_control/pages/lines/lines_state.dart';

class LinesBloc extends Bloc<LinesEvent, LinesState> {
  final Stream<Set<Line>> _trackedLines;
  StreamSubscription<Set<Line>> _trackedLinesSubscription;

  LinesBloc(this._trackedLines) {
    rootBundle.loadString('assets/json/lines.json').then((jsonString) {
      final lineItems = Map.fromIterable(
        jsonDecode(jsonString) as List,
        key: (lineJson) => Line.fromJson(lineJson),
        value: (_) => LineState.initial(),
      );
      add(LinesEvent.created(items: lineItems));
    });

    _trackedLinesSubscription = _trackedLines.listen(_trackedLinesChanged);
  }

  @override
  Future<void> close() async {
    await _trackedLinesSubscription.cancel();
    return super.close();
  }

  @override
  LinesState get initialState => LinesState.empty();

  @override
  Stream<LinesState> mapEventToState(LinesEvent event) async* {
    yield event.when(
      created: (created) => LinesState(items: created.items, filter: null),
      filterChanged: (filterChange) =>
          LinesState(items: state.items, filter: filterChange.filter),
      itemSelectionChanged: (selectionChange) {
        final oldLineState = state.items[selectionChange.item];
        if (oldLineState.tracked) return state;
        final updatedItems = Map.of(state.items);
        updatedItems[selectionChange.item] = oldLineState.toggleSelection;
        return LinesState(items: updatedItems, filter: state.filter);
      },
      selectionReset: (_) {
        final updatedItems = Map.of(state.items);
        updatedItems.forEach((key, value) {
          if (value.selected) updatedItems[key] = value.toggleSelection;
        });
        return LinesState(items: updatedItems, filter: state.filter);
      },
      trackedLinesChanged: (trackedLinesChange) {
        final updatedItems = Map.of(state.items);
        updatedItems.forEach((key, value) {
          if (value.tracked) updatedItems[key] = value.toggleTracked;
        });
        trackedLinesChange.lines
            .forEach((line) => updatedItems[line].toggleTracked);
        return LinesState(items: updatedItems, filter: state.filter);
      },
    );
  }

  Stream<List<MapEntry<Line, LineState>>> get filteredItemsStream =>
      map((state) => state.filter == null
          ? state.items.entries.toList()
          : state.items.entries
              .where((entry) => entry.key.symbol
                  .toLowerCase()
                  .contains(state.filter.trim().toLowerCase()))
              .toList());

  Set<Line> get selectedLines => state.selectedLines;

  Stream<Set<Line>> get selectedLinesStream {
    return map((state) => state.selectedLines);
  }

  void itemSelectionChanged(Line item) {
    add(LinesEvent.itemSelectionChanged(item: item));
  }

  void selectionReset() => add(LinesEvent.selectionReset());

  void filterChanged(String filter) {
    add(LinesEvent.filterChanged(filter: filter));
  }

  void _trackedLinesChanged(Iterable<Line> lines) {
    add(LinesEvent.trackedLinesChanged(lines: lines));
  }
}
