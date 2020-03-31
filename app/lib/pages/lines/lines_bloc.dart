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
      created: (created) => LinesState(
        items: created.items,
        symbolFilter: null,
        listFilter: LineListFilter.ALL,
      ),
      symbolFilterChanged: (filterChange) => state.copyWith(
        symbolFilter: filterChange.filter,
      ),
      listFilterChanged: (filterChange) => state.copyWith(
        listFilter: filterChange.filter,
      ),
      itemSelectionChanged: (selectionChange) {
        final oldLineState = state.items[selectionChange.item];
        if (oldLineState.tracked) return state;
        final updatedItems = Map.of(state.items);
        updatedItems[selectionChange.item] = oldLineState.toggleSelection;
        return state.copyWith(items: updatedItems);
      },
      selectionReset: (_) {
        final updatedItems = Map.of(state.items);
        updatedItems.forEach((key, value) {
          if (value.selected) updatedItems[key] = value.toggleSelection;
        });
        return state.copyWith(items: updatedItems);
      },
      trackedLinesChanged: (trackedLinesChange) {
        final updatedItems = Map.of(state.items);
        updatedItems.forEach((key, value) {
          if (value.tracked) updatedItems[key] = value.toggleTracked;
        });
        trackedLinesChange.lines
            .forEach((line) => updatedItems[line].toggleTracked);
        return state.copyWith(items: updatedItems);
      },
    );
  }

  Stream<List<MapEntry<Line, LineState>>> get filteredItemsStream {
    return map(
      (state) {
        final symbolFilterPred = state.symbolFilter == null
            ? (MapEntry<Line, LineState> entry) => true
            : (MapEntry<Line, LineState> entry) => entry.key.symbol
                .toLowerCase()
                .contains(state.symbolFilter.trim().toLowerCase());
        final listFilterPred = state.listFilterPredicate;
        return state.items.entries
            .where((entry) => symbolFilterPred(entry) && listFilterPred(entry))
            .toList();
      },
    );
  }

  Set<Line> get selectedLines => state.selectedLines;

  Stream<Set<Line>> get selectedLinesStream {
    return map((state) => state.selectedLines);
  }

  Stream<List<LineListFilter>> get listFiltersStream {
    return map(
      (state) {
        final availableFilters = LineListFilter.values
            .where((value) => value != state.listFilter)
            .toList();
        if (availableFilters.contains(LineListFilter.SELECTED) &&
            state.selectedLines.isEmpty) {
          availableFilters.remove(LineListFilter.SELECTED);
        }
        if (availableFilters.contains(LineListFilter.TRACKED) &&
            state.trackedLines.isEmpty) {
          availableFilters.remove(LineListFilter.TRACKED);
        }
        if (availableFilters.contains(LineListFilter.FAVOURITE) &&
            state.favouriteLines.isEmpty) {
          availableFilters.remove(LineListFilter.FAVOURITE);
        }
        return availableFilters;
      },
    );
  }

  void itemSelectionChanged(Line item) {
    add(LinesEvent.itemSelectionChanged(item: item));
  }

  void selectionReset() => add(LinesEvent.selectionReset());

  void symbolFilterChanged(String filter) {
    add(LinesEvent.symbolFilterChanged(filter: filter));
  }

  void listFilterChanged(LineListFilter filter) {
    add(LinesEvent.listFilterChanged(filter: filter));
  }

  void _trackedLinesChanged(Iterable<Line> lines) {
    add(LinesEvent.trackedLinesChanged(lines: lines));
  }
}
