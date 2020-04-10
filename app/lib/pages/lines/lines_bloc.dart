import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_event.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/util/asset_util.dart';

class LinesBloc extends Bloc<LinesEvent, LinesState> {
  final void Function(Set<Line>) _trackedLinesAdded;
  final void Function(Set<Line>) _trackedLinesRemoved;
  final LinesRepo _linesRepo;

  StreamSubscription<Set<Line>> _trackedLinesSubscription;
  StreamSubscription<Map<Line, LineState>> _linesSubscription;

  LinesBloc(
    this._trackedLinesAdded,
    this._trackedLinesRemoved,
    this._linesRepo,
  ) {
    _linesSubscription = _linesRepo.favouriteLinesStream.asyncMap(
      (favouriteLines) {
        if (state.lines.isEmpty) {
          return rootBundle
              .loadString(
                JsonAssets.lines,
              )
              .then(
                (jsonString) => Map.fromIterable(
                    jsonDecode(jsonString) as Iterable,
                    key: (lineJson) => Line.fromJson(lineJson),
                    value: (line) => favouriteLines.contains(line)
                        ? LineState.initialFavourite()
                        : LineState.initial()),
              );
        } else {
          return Future.value(state.lines.map((line, state) {
            final isFavourite = favouriteLines.contains(line);
            if ((state.favourite && !isFavourite) ||
                (!state.favourite && isFavourite)) {
              return MapEntry(line, state.toggleFavourite);
            } else {
              return MapEntry(line, state);
            }
          }));
        }
      },
    ).listen(
      (lines) => add(LinesEvent.created(lines: lines)),
    );
  }

  @override
  Future<void> close() async {
    await Future.wait(
        [_trackedLinesSubscription.cancel(), _linesSubscription.cancel()]);
    return super.close();
  }

  @override
  LinesState get initialState => LinesState.empty();

  @override
  Stream<LinesState> mapEventToState(LinesEvent event) async* {
    yield event.when(
      created: (created) => LinesState(
        lines: created.lines,
        symbolFilter: null,
        listFilter: LineListFilter.ALL,
      ),
      symbolFilterChanged: (filterChange) => state.copyWith(
        symbolFilter: filterChange.filter,
      ),
      listFilterChanged: (filterChange) => state.copyWith(
        listFilter: filterChange.filter,
      ),
      lineSelectionChanged: (selectionChange) {
        final oldLineState = state.lines[selectionChange.line];
        if (oldLineState.tracked) return state;
        final updatedLines = Map.of(state.lines);
        updatedLines[selectionChange.line] = oldLineState.toggleSelection;
        return state.copyWith(lines: updatedLines);
      },
      selectionReset: (_) {
        final updatedLines = Map.of(state.lines);
        updatedLines.forEach((key, value) {
          if (value.selected) updatedLines[key] = value.toggleSelection;
        });
        return state.copyWith(lines: updatedLines);
      },
      trackSelectedLines: (_) {
        final updatedLines = Map.of(state.lines);
        final newlyTrackedLines = Set<Line>();
        updatedLines.forEach((line, state) {
          if (!state.tracked && state.selected) {
            newlyTrackedLines.add(line);
            updatedLines[line] = state.toggleTracked;
          }
        });
        _trackedLinesAdded(newlyTrackedLines);
        return state.copyWith(lines: updatedLines);
      },
      untrackSelectedLines: (_) {
        final updatedLines = Map.of(state.lines);
        final linesRemovedFromTracking = Set<Line>();
        updatedLines.forEach((line, state) {
          if (state.tracked && state.selected) {
            linesRemovedFromTracking.add(line);
            updatedLines[line] = state.toggleTracked;
          }
        });
        _trackedLinesRemoved(linesRemovedFromTracking);
        return state.copyWith(lines: updatedLines);
      },
      loadingVehiclesOfLinesFailed: (loadingVehiclesOfLinesFailedEvent) {
        final updatedLines = Map.of(state.lines);
        updatedLines.forEach((line, state) {
          if (loadingVehiclesOfLinesFailedEvent.lines.contains(line)) {
            updatedLines[line] = state.toggleTracked;
          }
        });
        return state.copyWith(lines: updatedLines);
      },
      favouriteLinesUpdated: (favouriteLinesUpdatedEvent) {
        return state.copyWith(
          lines: state.lines.map((line, state) {
            final isFavourite = favouriteLinesUpdatedEvent.lines.contains(line);
            if ((state.favourite && !isFavourite) ||
                (!state.favourite && isFavourite)) {
              return MapEntry(line, state.toggleFavourite);
            } else {
              return MapEntry(line, state);
            }
          }),
        );
      },
    );
  }

  Stream<List<MapEntry<Line, LineState>>> get filteredLinesStream {
    return map(
      (state) {
        final symbolFilterPred = state.symbolFilter == null
            ? (MapEntry<Line, LineState> entry) => true
            : (MapEntry<Line, LineState> entry) => entry.key.symbol
                .toLowerCase()
                .contains(state.symbolFilter.trim().toLowerCase());
        final listFilterPred = state.listFilterPredicate;
        return state.lines.entries
            .where((entry) => symbolFilterPred(entry) && listFilterPred(entry))
            .toList();
      },
    );
  }

  Stream<Iterable<MapEntry<Line, LineState>>> get selectedLinesStream {
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

  void lineSelectionChanged(Line line) {
    add(LinesEvent.lineSelectionChanged(line: line));
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

  void addSelectedLinesToFavourites() {
    _linesRepo.insertLines(state.selectedLines.map((entry) => entry.key));
  }

  void removeSelectedLinesFromFavourites() {
    _linesRepo
        .deleteLines(state.selectedLines.map((entry) => entry.key.symbol));
  }
}
