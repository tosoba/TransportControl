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

  factory LinesEvent.lineSelectionChanged({@required Line line}) =
      LineSelectionChanged;

  factory LinesEvent.resetSelection() = ResetSelection;

  factory LinesEvent.trackSelectedLines() = TrackSelectedLines;

  factory LinesEvent.untrackSelectedLines() = UntrackSelectedLines;

  factory LinesEvent.loadingVehiclesOfLinesFailed({@required Set<Line> lines}) =
      LoadingVehiclesOfLinesFailed;

  final _LinesEvent _type;

//ignore: missing_return
  R when<R>(
      {@required
          R Function(UpdateLines) updateLines,
      @required
          R Function(SymbolFilterChanged) symbolFilterChanged,
      @required
          R Function(ListFilterChanged) listFilterChanged,
      @required
          R Function(LineSelectionChanged) lineSelectionChanged,
      @required
          R Function(ResetSelection) resetSelection,
      @required
          R Function(TrackSelectedLines) trackSelectedLines,
      @required
          R Function(UntrackSelectedLines) untrackSelectedLines,
      @required
          R Function(LoadingVehiclesOfLinesFailed)
              loadingVehiclesOfLinesFailed}) {
    assert(() {
      if (updateLines == null ||
          symbolFilterChanged == null ||
          listFilterChanged == null ||
          lineSelectionChanged == null ||
          resetSelection == null ||
          trackSelectedLines == null ||
          untrackSelectedLines == null ||
          loadingVehiclesOfLinesFailed == null) {
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
      case _LinesEvent.LineSelectionChanged:
        return lineSelectionChanged(this as LineSelectionChanged);
      case _LinesEvent.ResetSelection:
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.UntrackSelectedLines:
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.LoadingVehiclesOfLinesFailed:
        return loadingVehiclesOfLinesFailed(
            this as LoadingVehiclesOfLinesFailed);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(UpdateLines) updateLines,
      @required
          FutureOr<R> Function(SymbolFilterChanged) symbolFilterChanged,
      @required
          FutureOr<R> Function(ListFilterChanged) listFilterChanged,
      @required
          FutureOr<R> Function(LineSelectionChanged) lineSelectionChanged,
      @required
          FutureOr<R> Function(ResetSelection) resetSelection,
      @required
          FutureOr<R> Function(TrackSelectedLines) trackSelectedLines,
      @required
          FutureOr<R> Function(UntrackSelectedLines) untrackSelectedLines,
      @required
          FutureOr<R> Function(LoadingVehiclesOfLinesFailed)
              loadingVehiclesOfLinesFailed}) {
    assert(() {
      if (updateLines == null ||
          symbolFilterChanged == null ||
          listFilterChanged == null ||
          lineSelectionChanged == null ||
          resetSelection == null ||
          trackSelectedLines == null ||
          untrackSelectedLines == null ||
          loadingVehiclesOfLinesFailed == null) {
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
      case _LinesEvent.LineSelectionChanged:
        return lineSelectionChanged(this as LineSelectionChanged);
      case _LinesEvent.ResetSelection:
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.UntrackSelectedLines:
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.LoadingVehiclesOfLinesFailed:
        return loadingVehiclesOfLinesFailed(
            this as LoadingVehiclesOfLinesFailed);
    }
  }

  R whenOrElse<R>(
      {R Function(UpdateLines) updateLines,
      R Function(SymbolFilterChanged) symbolFilterChanged,
      R Function(ListFilterChanged) listFilterChanged,
      R Function(LineSelectionChanged) lineSelectionChanged,
      R Function(ResetSelection) resetSelection,
      R Function(TrackSelectedLines) trackSelectedLines,
      R Function(UntrackSelectedLines) untrackSelectedLines,
      R Function(LoadingVehiclesOfLinesFailed) loadingVehiclesOfLinesFailed,
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
      case _LinesEvent.LineSelectionChanged:
        if (lineSelectionChanged == null) break;
        return lineSelectionChanged(this as LineSelectionChanged);
      case _LinesEvent.ResetSelection:
        if (resetSelection == null) break;
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        if (trackSelectedLines == null) break;
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.UntrackSelectedLines:
        if (untrackSelectedLines == null) break;
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.LoadingVehiclesOfLinesFailed:
        if (loadingVehiclesOfLinesFailed == null) break;
        return loadingVehiclesOfLinesFailed(
            this as LoadingVehiclesOfLinesFailed);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(UpdateLines) updateLines,
      FutureOr<R> Function(SymbolFilterChanged) symbolFilterChanged,
      FutureOr<R> Function(ListFilterChanged) listFilterChanged,
      FutureOr<R> Function(LineSelectionChanged) lineSelectionChanged,
      FutureOr<R> Function(ResetSelection) resetSelection,
      FutureOr<R> Function(TrackSelectedLines) trackSelectedLines,
      FutureOr<R> Function(UntrackSelectedLines) untrackSelectedLines,
      FutureOr<R> Function(LoadingVehiclesOfLinesFailed)
          loadingVehiclesOfLinesFailed,
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
      case _LinesEvent.LineSelectionChanged:
        if (lineSelectionChanged == null) break;
        return lineSelectionChanged(this as LineSelectionChanged);
      case _LinesEvent.ResetSelection:
        if (resetSelection == null) break;
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        if (trackSelectedLines == null) break;
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.UntrackSelectedLines:
        if (untrackSelectedLines == null) break;
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.LoadingVehiclesOfLinesFailed:
        if (loadingVehiclesOfLinesFailed == null) break;
        return loadingVehiclesOfLinesFailed(
            this as LoadingVehiclesOfLinesFailed);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(UpdateLines) updateLines,
      FutureOr<void> Function(SymbolFilterChanged) symbolFilterChanged,
      FutureOr<void> Function(ListFilterChanged) listFilterChanged,
      FutureOr<void> Function(LineSelectionChanged) lineSelectionChanged,
      FutureOr<void> Function(ResetSelection) resetSelection,
      FutureOr<void> Function(TrackSelectedLines) trackSelectedLines,
      FutureOr<void> Function(UntrackSelectedLines) untrackSelectedLines,
      FutureOr<void> Function(LoadingVehiclesOfLinesFailed)
          loadingVehiclesOfLinesFailed}) {
    assert(() {
      if (updateLines == null &&
          symbolFilterChanged == null &&
          listFilterChanged == null &&
          lineSelectionChanged == null &&
          resetSelection == null &&
          trackSelectedLines == null &&
          untrackSelectedLines == null &&
          loadingVehiclesOfLinesFailed == null) {
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
      case _LinesEvent.LineSelectionChanged:
        if (lineSelectionChanged == null) break;
        return lineSelectionChanged(this as LineSelectionChanged);
      case _LinesEvent.ResetSelection:
        if (resetSelection == null) break;
        return resetSelection(this as ResetSelection);
      case _LinesEvent.TrackSelectedLines:
        if (trackSelectedLines == null) break;
        return trackSelectedLines(this as TrackSelectedLines);
      case _LinesEvent.UntrackSelectedLines:
        if (untrackSelectedLines == null) break;
        return untrackSelectedLines(this as UntrackSelectedLines);
      case _LinesEvent.LoadingVehiclesOfLinesFailed:
        if (loadingVehiclesOfLinesFailed == null) break;
        return loadingVehiclesOfLinesFailed(
            this as LoadingVehiclesOfLinesFailed);
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
class LineSelectionChanged extends LinesEvent {
  const LineSelectionChanged({@required this.line})
      : super(_LinesEvent.LineSelectionChanged);

  final Line line;

  @override
  String toString() => 'LineSelectionChanged(line:${this.line})';
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
  const TrackSelectedLines._() : super(_LinesEvent.TrackSelectedLines);

  factory TrackSelectedLines() {
    _instance ??= const TrackSelectedLines._();
    return _instance;
  }

  static TrackSelectedLines _instance;
}

@immutable
class UntrackSelectedLines extends LinesEvent {
  const UntrackSelectedLines._() : super(_LinesEvent.UntrackSelectedLines);

  factory UntrackSelectedLines() {
    _instance ??= const UntrackSelectedLines._();
    return _instance;
  }

  static UntrackSelectedLines _instance;
}

@immutable
class LoadingVehiclesOfLinesFailed extends LinesEvent {
  const LoadingVehiclesOfLinesFailed({@required this.lines})
      : super(_LinesEvent.LoadingVehiclesOfLinesFailed);

  final Set<Line> lines;

  @override
  String toString() => 'LoadingVehiclesOfLinesFailed(lines:${this.lines})';
  @override
  List get props => [lines];
}
