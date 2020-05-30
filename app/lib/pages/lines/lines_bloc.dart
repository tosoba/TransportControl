import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/di/module/controllers_module.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_event.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/util/asset_util.dart';

class LinesBloc extends Bloc<LinesEvent, LinesState> {
  final LinesRepo _linesRepo;
  final Sink<TrackedLinesAddedEvent> _trackedLinesAddedSink;
  final Sink<Set<Line>> _trackedLinesRemovedSink;

  final List<StreamSubscription> _subscriptions = [];

  LinesBloc(
    this._linesRepo,
    this._trackedLinesAddedSink,
    this._trackedLinesRemovedSink,
    Stream<Set<Line>> untrackLinesStream,
    Stream<Object> untrackAllLinesStream,
  ) {
    _subscriptions
      ..add(
        _linesRepo.favouriteLinesStream
            .asyncMap(
              (favouriteLines) => state.lines.isEmpty
                  ? rootBundle.loadString(JsonAssets.lines).then(
                        (jsonString) => Map.fromIterable(
                          jsonDecode(jsonString) as Iterable,
                          key: (lineJson) => Line.fromJson(lineJson),
                          value: (line) => favouriteLines.contains(line)
                              ? LineState.initialFavourite()
                              : LineState.initial(),
                        ),
                      )
                  : Future.value(
                      state.lines.map((line, state) {
                        final isFavourite = favouriteLines.contains(line);
                        if ((state.favourite && !isFavourite) ||
                            (!state.favourite && isFavourite)) {
                          return MapEntry(line, state.toggleFavourite);
                        } else {
                          return MapEntry(line, state);
                        }
                      }),
                    ),
            )
            .listen((lines) => add(LinesEvent.updateLines(lines: lines))),
      )
      ..add(
        untrackLinesStream.listen(
          (lines) => add(LinesEvent.toggleLinesTracking(lines: lines)),
        ),
      )
      ..add(
        untrackAllLinesStream.listen((_) => add(LinesEvent.untrackAllLines())),
      );
  }

  @override
  Future<void> close() async {
    await Future.wait(
      _subscriptions.map((subscription) => subscription.cancel()),
    );
    return super.close();
  }

  @override
  LinesState get initialState => LinesState.initial();

  @override
  Stream<LinesState> mapEventToState(LinesEvent event) async* {
    yield event.when(
      updateLines: (evt) => state.copyWith(lines: evt.lines),
      symbolFilterChanged: (evt) => state.copyWith(symbolFilter: evt.filter),
      listFilterChanged: (evt) => state.copyWith(listFilter: evt.filter),
      toggleLineSelection: (evt) {
        final oldLineState = state.lines[evt.line];
        final updatedLines = Map.of(state.lines);
        updatedLines[evt.line] = oldLineState.toggleSelection;
        return state.copyWith(lines: updatedLines);
      },
      resetSelection: (_) => state.copyWith(
        lines: state.lines.map(
          (line, lineState) => lineState.selected
              ? MapEntry(line, lineState.toggleSelection)
              : MapEntry(line, lineState),
        ),
      ),
      trackSelectedLines: (evt) {
        final updatedLines = Map.of(state.lines);
        final newlyTrackedLines = Set<Line>();
        final toggle = evt.resetSelection
            ? (LineState state) => state.toggleTrackedAndSelection
            : (LineState state) => state.toggleTracked;
        updatedLines.forEach((line, lineState) {
          if (!lineState.tracked && lineState.selected) {
            newlyTrackedLines.add(line);
            updatedLines[line] = toggle(lineState);
          }
        });
        _trackedLinesAddedSink.add(
          TrackedLinesAddedEvent(
            lines: newlyTrackedLines,
            beforeRetry: () {
              add(LinesEvent.toggleLinesTracking(lines: newlyTrackedLines));
            },
          ),
        );
        return state.copyWith(lines: updatedLines);
      },
      untrackSelectedLines: (evt) {
        final updatedLines = Map.of(state.lines);
        final linesRemovedFromTracking = Set<Line>();
        final toggle = evt.resetSelection
            ? (LineState state) => state.toggleTrackedAndSelection
            : (LineState state) => state.toggleTracked;
        updatedLines.forEach((line, lineState) {
          if (lineState.tracked && lineState.selected) {
            linesRemovedFromTracking.add(line);
            updatedLines[line] = toggle(lineState);
          }
        });
        _trackedLinesRemovedSink.add(linesRemovedFromTracking);
        return state.copyWith(lines: updatedLines);
      },
      untrackAllLines: (_) => state.copyWith(
        lines: state.lines.map(
          (line, lineState) => MapEntry(line, lineState.untracked),
        ),
      ),
      toggleLinesTracking: (evt) => state.copyWith(
        lines: state.lines.map(
          (line, lineState) => evt.lines.contains(line)
              ? MapEntry(line, lineState.toggleTracked)
              : MapEntry(line, lineState),
        ),
      ),
      toggleLineFavourite: (evt) => state.copyWith(
        lines: state.lines.map(
          (line, lineState) => evt.line == line
              ? MapEntry(line, lineState.toggleFavourite)
              : MapEntry(line, lineState),
        ),
      ),
      toggleLineTracking: (evt) => state.copyWith(
        lines: state.lines.map(
          (line, lineState) => evt.line == line
              ? MapEntry(line, lineState.toggleTracked)
              : MapEntry(line, lineState),
        ),
      ),
    );
  }

  Stream<List<MapEntry<Line, LineState>>> get filteredLinesStream {
    return map(
      (state) {
        final symbolFilterPred = state.symbolFilterPredicate;
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
        final availableFilters = List.of(LineListFilter.values)
          ..remove(state.listFilter);
        if (state.selectedLines.isEmpty) {
          availableFilters.remove(LineListFilter.selected);
        }
        if (state.trackedLines.isEmpty) {
          availableFilters.remove(LineListFilter.tracked);
        }
        if (state.favouriteLines.isEmpty) {
          availableFilters.remove(LineListFilter.favourite);
        }
        return availableFilters;
      },
    );
  }

  Stream<String> get symbolFiltersStream => map((state) => state.symbolFilter);

  void toggleSelected(Line line) {
    add(LinesEvent.toggleLineSelection(line: line));
  }

  void toggleFavourite(Line line) {
    add(LinesEvent.toggleLineFavourite(line: line));
  }

  void toggleTracked(MapEntry<Line, LineState> line) async {
    if (line.value.tracked) {
      _trackedLinesRemovedSink.add(Set<Line>()..add(line.key));
    } else {
      _trackedLinesAddedSink.add(
        TrackedLinesAddedEvent(
          lines: Set<Line>()..add(line.key),
          beforeRetry: () {
            add(LinesEvent.toggleLineTracking(line: line.key));
          },
        ),
      );
    }
    add(LinesEvent.toggleLineTracking(line: line.key));
  }

  void resetSelection() => add(LinesEvent.resetSelection());

  void symbolFilterChanged(String filter) {
    add(LinesEvent.symbolFilterChanged(filter: filter));
  }

  void listFilterChanged(LineListFilter filter) {
    add(LinesEvent.listFilterChanged(filter: filter));
  }

  void trackSelectedLines({bool resetSelection = true}) async {
    add(LinesEvent.trackSelectedLines(resetSelection: resetSelection));
  }

  void untrackSelectedLines({bool resetSelection = true}) {
    add(LinesEvent.untrackSelectedLines(resetSelection: resetSelection));
  }

  void addSelectedLinesToFavourites({bool resetSelection = true}) {
    _linesRepo.insertLines(state.selectedLines.map((entry) => entry.key));
    if (resetSelection) this.resetSelection();
  }

  void removeSelectedLinesFromFavourites({bool resetSelection = true}) {
    _linesRepo
        .deleteLines(state.selectedLines.map((entry) => entry.key.symbol));
    if (resetSelection) this.resetSelection();
  }
}
