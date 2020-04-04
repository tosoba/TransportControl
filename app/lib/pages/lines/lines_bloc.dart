import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_event.dart';
import 'package:transport_control/pages/lines/lines_state.dart';

class LinesBloc extends Bloc<LinesEvent, LinesState> {
  final void Function(Set<Line>) _trackedLinesAdded;
  final void Function(Set<Line>) _trackedLinesRemoved;

  StreamSubscription<Set<Line>> _trackedLinesSubscription;

  LinesBloc(
    this._trackedLinesAdded,
    this._trackedLinesRemoved,
  ) {
    rootBundle.loadString('assets/json/lines.json').then((jsonString) {
      final lineItems = Map.fromIterable(
        jsonDecode(jsonString) as List,
        key: (lineJson) => Line.fromJson(lineJson),
        value: (_) => LineState.initial(),
      );
      add(LinesEvent.created(items: lineItems));
    });
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
      trackSelectedLines: (_) {
        final updatedItems = Map.of(state.items);
        final newlyTrackedLines = Set<Line>();
        updatedItems.forEach((line, state) {
          if (!state.tracked && state.selected) {
            newlyTrackedLines.add(line);
            updatedItems[line] = state.toggleTracked;
          }
        });
        _trackedLinesAdded(newlyTrackedLines);
        return state.copyWith(items: updatedItems);
      },
      untrackSelectedLines: (_) {
        final updatedItems = Map.of(state.items);
        final linesRemovedFromTracking = Set<Line>();
        updatedItems.forEach((line, state) {
          if (state.tracked && state.selected) {
            linesRemovedFromTracking.add(line);
            updatedItems[line] = state.toggleTracked;
          }
        });
        _trackedLinesRemoved(linesRemovedFromTracking);
        return state.copyWith(items: updatedItems);
      },
      loadingVehiclesOfLinesFailed: (loadingVehiclesOfLinesFailedEvent) {
        final updatedItems = Map.of(state.items);
        updatedItems.forEach((line, state) {
          if (loadingVehiclesOfLinesFailedEvent.lines.contains(line)) {
            updatedItems[line] = state.toggleTracked;
          }
        });
        return state;
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

  void trackSelectedLines() {
    add(LinesEvent.trackSelectedLines());
  }

  void untrackSelectedLines() {
    add(LinesEvent.untrackSelectedLines());
  }

  void loadingVehiclesOfLinesFailed(Set<Line> lines) {
    add(LinesEvent.loadingVehiclesOfLinesFailed(lines: lines));
  }
}
