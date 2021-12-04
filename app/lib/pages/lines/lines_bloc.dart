import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/di/module/controllers_module.dart'
    as Controllers;
import 'package:transport_control/model/line.dart';
import 'package:transport_control/pages/lines/lines_event.dart';
import 'package:transport_control/pages/lines/lines_state.dart';
import 'package:transport_control/repo/lines_repo.dart';
import 'package:transport_control/util/asset_util.dart';

class LinesBloc extends Bloc<LinesEvent, LinesState> {
  final LinesRepo _linesRepo;
  final Sink<Controllers.TrackedLinesAddedEvent> _trackedLinesAddedSink;
  final Sink<Set<Line>> _trackedLinesRemovedSink;

  final List<StreamSubscription> _subscriptions = [];

  LinesBloc(
    this._linesRepo,
    this._trackedLinesAddedSink,
    this._trackedLinesRemovedSink,
    Stream<Set<Line>> untrackLinesStream,
    Stream<Object> untrackAllLinesStream,
  ) : super(LinesState.initial()) {
    on<UpdateLines>((event, emit) => emit(state.copyWith(lines: event.lines)));
    on<SymbolFilterChanged>(
      (event, emit) => emit(state.copyWith(symbolFilter: event.filter)),
    );
    on<ListFilterChanged>(
      (event, emit) => emit(state.copyWith(listFilter: event.filter)),
    );
    on<ToggleLineSelection>(
      (event, emit) {
        final oldLineState = state.lines[event.line];
        final updatedLines = Map.of(state.lines);
        updatedLines[event.line] = oldLineState.toggleSelection;
        emit(state.copyWith(lines: updatedLines));
      },
    );
    on<ResetSelection>(
      (event, emit) => emit(state.copyWith(
        lines: state.lines.map(
          (line, lineState) => lineState.selected
              ? MapEntry(line, lineState.toggleSelection)
              : MapEntry(line, lineState),
        ),
      )),
    );
    on<TrackSelectedLines>(
      (event, emit) {
        final updatedLines = Map.of(state.lines);
        final newlyTrackedLines = Set<Line>();
        final toggle = event.resetSelection
            ? (LineState state) => state.toggleTrackedAndSelection
            : (LineState state) => state.toggleTracked;
        updatedLines.forEach((line, lineState) {
          if (!lineState.tracked && lineState.selected) {
            newlyTrackedLines.add(line);
            updatedLines[line] = toggle(lineState);
          }
        });

        _linesRepo
            .updateLastSearched(newlyTrackedLines.map((line) => line.symbol));

        _trackedLinesAddedSink.add(
          Controllers.TrackedLinesAddedEvent(
            lines: newlyTrackedLines,
            beforeRetry: () {
              add(LinesEvent.toggleLinesTracking(lines: newlyTrackedLines));
            },
          ),
        );

        emit(state.copyWith(lines: updatedLines));
      },
    );
    on<UntrackSelectedLines>((event, emit) {
      final updatedLines = Map.of(state.lines);
      final linesRemovedFromTracking = Set<Line>();
      final toggle = event.resetSelection
          ? (LineState state) => state.toggleTrackedAndSelection
          : (LineState state) => state.toggleTracked;
      updatedLines.forEach((line, lineState) {
        if (lineState.tracked && lineState.selected) {
          linesRemovedFromTracking.add(line);
          updatedLines[line] = toggle(lineState);
        }
      });

      _trackedLinesRemovedSink.add(linesRemovedFromTracking);

      emit(state.copyWith(lines: updatedLines));
    });
    on<UntrackAllLines>(
      (event, emit) => emit(state.copyWith(
        lines: state.lines.map(
          (line, lineState) => MapEntry(line, lineState.untracked),
        ),
      )),
    );
    on<ToggleLinesTracking>(
      (event, emit) => emit(
        state.copyWith(
          lines: state.lines.map(
            (line, lineState) => event.lines.contains(line)
                ? MapEntry(line, lineState.toggleTracked)
                : MapEntry(line, lineState),
          ),
        ),
      ),
    );
    on<ToggleLineTracking>(
      (event, emit) => emit(
        state.copyWith(
          lines: state.lines.map(
            (line, lineState) => event.line == line
                ? MapEntry(line, lineState.toggleTracked)
                : MapEntry(line, lineState),
          ),
        ),
      ),
    );

    _subscriptions
      ..add(
        _linesRepo.linesStream
            .tap((lines) async {
              if (lines.isEmpty) {
                final linesJsonString =
                    await rootBundle.loadString(JsonAssets.lines);
                _linesRepo.insertLines(
                  (jsonDecode(linesJsonString) as Iterable)
                      .map((lineJson) => Line.fromJson(lineJson)),
                );
              }
            })
            .where((lines) => lines.isNotEmpty)
            .map(
              (lines) => Map.fromIterable(
                lines,
                key: (line) => line as Line,
                value: (line) => state.lines[line] ?? LineState.initial(),
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

  void toggleSelected(Line line) {
    add(LinesEvent.toggleLineSelection(line: line));
  }

  void toggleFavourite(Line line) {
    _linesRepo.updateIsFavourite([line]);
  }

  void toggleTracked(MapEntry<Line, LineState> line) {
    if (line.value.tracked) {
      _trackedLinesRemovedSink.add({line.key});
    } else {
      _trackedLinesAddedSink.add(
        Controllers.TrackedLinesAddedEvent(
          lines: {line.key},
          beforeRetry: () => add(LinesEvent.toggleLineTracking(line: line.key)),
        ),
      );
    }

    _linesRepo.updateLastSearched([line.key.symbol]);

    add(LinesEvent.toggleLineTracking(line: line.key));
  }

  void track(Line line) {
    _trackedLinesAddedSink.add(
      Controllers.TrackedLinesAddedEvent(
        lines: {line},
        beforeRetry: () => add(LinesEvent.toggleLineTracking(line: line)),
      ),
    );

    _linesRepo.updateLastSearched([line.symbol]);

    add(LinesEvent.toggleLineTracking(line: line));
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

  void toggleSelectedLinesFavourite(bool delete, {bool resetSelection = true}) {
    final filter = delete
        ? (MapEntry<Line, LineState> entry) => entry.key.isFavourite
        : (MapEntry<Line, LineState> entry) => !entry.key.isFavourite;
    _linesRepo.updateIsFavourite(
      state.selectedLines.where(filter).map((entry) => entry.key),
    );
    if (resetSelection) this.resetSelection();
  }
}
