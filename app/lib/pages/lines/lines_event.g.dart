// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lines_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LinesEvent extends Equatable {
  const LinesEvent(this._type);

  factory LinesEvent.updateLines({@required Map<Line, LineState> lines}) =
      UpdateLines;

  factory LinesEvent.symbolFilterChanged({@required String filter}) =
      SymbolFilterChanged;

  factory LinesEvent.listFilterChanged({@required LineListFilter filter}) =
      ListFilterChanged;

  factory LinesEvent.toggleLineSelection({@required Line line}) =
      ToggleLineSelection;

  factory LinesEvent.toggleLineTracking({@required Line line}) =
      ToggleLineTracking;

  factory LinesEvent.resetSelection() = ResetSelection;

  factory LinesEvent.trackSelectedLines({@required bool resetSelection}) =
      TrackSelectedLines;

  factory LinesEvent.toggleLinesTracking({@required Set<Line> lines}) =
      ToggleLinesTracking;

  factory LinesEvent.untrackSelectedLines({@required bool resetSelection}) =
      UntrackSelectedLines;

  factory LinesEvent.untrackAllLines() = UntrackAllLines;

  final _LinesEvent _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(UpdateLines) updateLines,
      @required R Function(SymbolFilterChanged) symbolFilterChanged,
      @required R Function(ListFilterChanged) listFilterChanged,
      @required R Function(ToggleLineSelection) toggleLineSelection,
      @required R Function(ToggleLineTracking) toggleLineTracking,
      @required R Function(ResetSelection) resetSelection,
      @required R Function(TrackSelectedLines) trackSelectedLines,
      @required R Function(ToggleLinesTracking) toggleLinesTracking,
      @required R Function(UntrackSelectedLines) untrackSelectedLines,
      @required R Function(UntrackAllLines) untrackAllLines}) {
    assert(() {
      if (updateLines == null ||
          symbolFilterChanged == null ||
          listFilterChanged == null ||
          toggleLineSelection == null ||
          toggleLineTracking == null ||
          resetSelection == null ||
          trackSelectedLines == null ||
          toggleLinesTracking == null ||
          untrackSelectedLines == null ||
          untrackAllLines == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.UpdateLines:
        return updateLines(this as UpdateLines);
      case _LinesEvent.SymbolFilterChanged:
        return symbolFilterChanged(this as SymbolFilterChanged);
      case _LinesEvent.ListFilterChanged:
        return listFilterChanged(this as ListFilterChanged);
      case _LinesEvent.ToggleLineSelection:
        return toggleLineSelection(this as ToggleLineSelection);
      case _LinesEvent.ToggleLineTracking:
        return toggleLineTracking(this as ToggleLineTracking);
      case _LinesEvent.ResetSelection:
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.ToggleLinesTracking:
        return toggleLinesTracking(this as ToggleLinesTracking);
      case _LinesEvent.UntrackSelectedLines:
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.UntrackAllLines:
        return untrackAllLines(this as UntrackAllLines);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required FutureOr<R> Function(UpdateLines) updateLines,
      @required FutureOr<R> Function(SymbolFilterChanged) symbolFilterChanged,
      @required FutureOr<R> Function(ListFilterChanged) listFilterChanged,
      @required FutureOr<R> Function(ToggleLineSelection) toggleLineSelection,
      @required FutureOr<R> Function(ToggleLineTracking) toggleLineTracking,
      @required FutureOr<R> Function(ResetSelection) resetSelection,
      @required FutureOr<R> Function(TrackSelectedLines) trackSelectedLines,
      @required FutureOr<R> Function(ToggleLinesTracking) toggleLinesTracking,
      @required FutureOr<R> Function(UntrackSelectedLines) untrackSelectedLines,
      @required FutureOr<R> Function(UntrackAllLines) untrackAllLines}) {
    assert(() {
      if (updateLines == null ||
          symbolFilterChanged == null ||
          listFilterChanged == null ||
          toggleLineSelection == null ||
          toggleLineTracking == null ||
          resetSelection == null ||
          trackSelectedLines == null ||
          toggleLinesTracking == null ||
          untrackSelectedLines == null ||
          untrackAllLines == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.UpdateLines:
        return updateLines(this as UpdateLines);
      case _LinesEvent.SymbolFilterChanged:
        return symbolFilterChanged(this as SymbolFilterChanged);
      case _LinesEvent.ListFilterChanged:
        return listFilterChanged(this as ListFilterChanged);
      case _LinesEvent.ToggleLineSelection:
        return toggleLineSelection(this as ToggleLineSelection);
      case _LinesEvent.ToggleLineTracking:
        return toggleLineTracking(this as ToggleLineTracking);
      case _LinesEvent.ResetSelection:
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.ToggleLinesTracking:
        return toggleLinesTracking(this as ToggleLinesTracking);
      case _LinesEvent.UntrackSelectedLines:
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.UntrackAllLines:
        return untrackAllLines(this as UntrackAllLines);
    }
  }

  R whenOrElse<R>(
      {R Function(UpdateLines) updateLines,
      R Function(SymbolFilterChanged) symbolFilterChanged,
      R Function(ListFilterChanged) listFilterChanged,
      R Function(ToggleLineSelection) toggleLineSelection,
      R Function(ToggleLineTracking) toggleLineTracking,
      R Function(ResetSelection) resetSelection,
      R Function(TrackSelectedLines) trackSelectedLines,
      R Function(ToggleLinesTracking) toggleLinesTracking,
      R Function(UntrackSelectedLines) untrackSelectedLines,
      R Function(UntrackAllLines) untrackAllLines,
      @required R Function(LinesEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.UpdateLines:
        if (updateLines == null) break;
        return updateLines(this as UpdateLines);
      case _LinesEvent.SymbolFilterChanged:
        if (symbolFilterChanged == null) break;
        return symbolFilterChanged(this as SymbolFilterChanged);
      case _LinesEvent.ListFilterChanged:
        if (listFilterChanged == null) break;
        return listFilterChanged(this as ListFilterChanged);
      case _LinesEvent.ToggleLineSelection:
        if (toggleLineSelection == null) break;
        return toggleLineSelection(this as ToggleLineSelection);
      case _LinesEvent.ToggleLineTracking:
        if (toggleLineTracking == null) break;
        return toggleLineTracking(this as ToggleLineTracking);
      case _LinesEvent.ResetSelection:
        if (resetSelection == null) break;
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        if (trackSelectedLines == null) break;
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.ToggleLinesTracking:
        if (toggleLinesTracking == null) break;
        return toggleLinesTracking(this as ToggleLinesTracking);
      case _LinesEvent.UntrackSelectedLines:
        if (untrackSelectedLines == null) break;
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.UntrackAllLines:
        if (untrackAllLines == null) break;
        return untrackAllLines(this as UntrackAllLines);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(UpdateLines) updateLines,
      FutureOr<R> Function(SymbolFilterChanged) symbolFilterChanged,
      FutureOr<R> Function(ListFilterChanged) listFilterChanged,
      FutureOr<R> Function(ToggleLineSelection) toggleLineSelection,
      FutureOr<R> Function(ToggleLineTracking) toggleLineTracking,
      FutureOr<R> Function(ResetSelection) resetSelection,
      FutureOr<R> Function(TrackSelectedLines) trackSelectedLines,
      FutureOr<R> Function(ToggleLinesTracking) toggleLinesTracking,
      FutureOr<R> Function(UntrackSelectedLines) untrackSelectedLines,
      FutureOr<R> Function(UntrackAllLines) untrackAllLines,
      @required FutureOr<R> Function(LinesEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.UpdateLines:
        if (updateLines == null) break;
        return updateLines(this as UpdateLines);
      case _LinesEvent.SymbolFilterChanged:
        if (symbolFilterChanged == null) break;
        return symbolFilterChanged(this as SymbolFilterChanged);
      case _LinesEvent.ListFilterChanged:
        if (listFilterChanged == null) break;
        return listFilterChanged(this as ListFilterChanged);
      case _LinesEvent.ToggleLineSelection:
        if (toggleLineSelection == null) break;
        return toggleLineSelection(this as ToggleLineSelection);
      case _LinesEvent.ToggleLineTracking:
        if (toggleLineTracking == null) break;
        return toggleLineTracking(this as ToggleLineTracking);
      case _LinesEvent.ResetSelection:
        if (resetSelection == null) break;
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        if (trackSelectedLines == null) break;
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.ToggleLinesTracking:
        if (toggleLinesTracking == null) break;
        return toggleLinesTracking(this as ToggleLinesTracking);
      case _LinesEvent.UntrackSelectedLines:
        if (untrackSelectedLines == null) break;
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.UntrackAllLines:
        if (untrackAllLines == null) break;
        return untrackAllLines(this as UntrackAllLines);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(UpdateLines) updateLines,
      FutureOr<void> Function(SymbolFilterChanged) symbolFilterChanged,
      FutureOr<void> Function(ListFilterChanged) listFilterChanged,
      FutureOr<void> Function(ToggleLineSelection) toggleLineSelection,
      FutureOr<void> Function(ToggleLineTracking) toggleLineTracking,
      FutureOr<void> Function(ResetSelection) resetSelection,
      FutureOr<void> Function(TrackSelectedLines) trackSelectedLines,
      FutureOr<void> Function(ToggleLinesTracking) toggleLinesTracking,
      FutureOr<void> Function(UntrackSelectedLines) untrackSelectedLines,
      FutureOr<void> Function(UntrackAllLines) untrackAllLines}) {
    assert(() {
      if (updateLines == null &&
          symbolFilterChanged == null &&
          listFilterChanged == null &&
          toggleLineSelection == null &&
          toggleLineTracking == null &&
          resetSelection == null &&
          trackSelectedLines == null &&
          toggleLinesTracking == null &&
          untrackSelectedLines == null &&
          untrackAllLines == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.UpdateLines:
        if (updateLines == null) break;
        return updateLines(this as UpdateLines);
      case _LinesEvent.SymbolFilterChanged:
        if (symbolFilterChanged == null) break;
        return symbolFilterChanged(this as SymbolFilterChanged);
      case _LinesEvent.ListFilterChanged:
        if (listFilterChanged == null) break;
        return listFilterChanged(this as ListFilterChanged);
      case _LinesEvent.ToggleLineSelection:
        if (toggleLineSelection == null) break;
        return toggleLineSelection(this as ToggleLineSelection);
      case _LinesEvent.ToggleLineTracking:
        if (toggleLineTracking == null) break;
        return toggleLineTracking(this as ToggleLineTracking);
      case _LinesEvent.ResetSelection:
        if (resetSelection == null) break;
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        if (trackSelectedLines == null) break;
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.ToggleLinesTracking:
        if (toggleLinesTracking == null) break;
        return toggleLinesTracking(this as ToggleLinesTracking);
      case _LinesEvent.UntrackSelectedLines:
        if (untrackSelectedLines == null) break;
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.UntrackAllLines:
        if (untrackAllLines == null) break;
        return untrackAllLines(this as UntrackAllLines);
    }
  }

  @override
  List get props => const [];
}

@immutable
class UpdateLines extends LinesEvent {
  const UpdateLines({@required this.lines}) : super(_LinesEvent.UpdateLines);

  final Map<Line, LineState> lines;

  @override
  String toString() => 'UpdateLines(lines:${this.lines})';
  @override
  List get props => [lines];
}

@immutable
class SymbolFilterChanged extends LinesEvent {
  const SymbolFilterChanged({@required this.filter})
      : super(_LinesEvent.SymbolFilterChanged);

  final String filter;

  @override
  String toString() => 'SymbolFilterChanged(filter:${this.filter})';
  @override
  List get props => [filter];
}

@immutable
class ListFilterChanged extends LinesEvent {
  const ListFilterChanged({@required this.filter})
      : super(_LinesEvent.ListFilterChanged);

  final LineListFilter filter;

  @override
  String toString() => 'ListFilterChanged(filter:${this.filter})';
  @override
  List get props => [filter];
}

@immutable
class ToggleLineSelection extends LinesEvent {
  const ToggleLineSelection({@required this.line})
      : super(_LinesEvent.ToggleLineSelection);

  final Line line;

  @override
  String toString() => 'ToggleLineSelection(line:${this.line})';
  @override
  List get props => [line];
}

@immutable
class ToggleLineTracking extends LinesEvent {
  const ToggleLineTracking({@required this.line})
      : super(_LinesEvent.ToggleLineTracking);

  final Line line;

  @override
  String toString() => 'ToggleLineTracking(line:${this.line})';
  @override
  List get props => [line];
}

@immutable
class ResetSelection extends LinesEvent {
  const ResetSelection._() : super(_LinesEvent.ResetSelection);

  factory ResetSelection() {
    _instance ??= const ResetSelection._();
    return _instance;
  }

  static ResetSelection _instance;
}

@immutable
class TrackSelectedLines extends LinesEvent {
  const TrackSelectedLines({@required this.resetSelection})
      : super(_LinesEvent.TrackSelectedLines);

  final bool resetSelection;

  @override
  String toString() =>
      'TrackSelectedLines(resetSelection:${this.resetSelection})';
  @override
  List get props => [resetSelection];
}

@immutable
class ToggleLinesTracking extends LinesEvent {
  const ToggleLinesTracking({@required this.lines})
      : super(_LinesEvent.ToggleLinesTracking);

  final Set<Line> lines;

  @override
  String toString() => 'ToggleLinesTracking(lines:${this.lines})';
  @override
  List get props => [lines];
}

@immutable
class UntrackSelectedLines extends LinesEvent {
  const UntrackSelectedLines({@required this.resetSelection})
      : super(_LinesEvent.UntrackSelectedLines);

  final bool resetSelection;

  @override
  String toString() =>
      'UntrackSelectedLines(resetSelection:${this.resetSelection})';
  @override
  List get props => [resetSelection];
}

@immutable
class UntrackAllLines extends LinesEvent {
  const UntrackAllLines._() : super(_LinesEvent.UntrackAllLines);

  factory UntrackAllLines() {
    _instance ??= const UntrackAllLines._();
    return _instance;
  }

  static UntrackAllLines _instance;
}
