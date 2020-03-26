// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lines_event.dart';

// **************************************************************************
// SuperEnumGenerator
// **************************************************************************

@immutable
abstract class LinesEvent extends Equatable {
  const LinesEvent(this._type);

  factory LinesEvent.created({@required Map<Line, LineState> items}) = Created;

  factory LinesEvent.filterChanged({@required String filter}) = FilterChanged;

  factory LinesEvent.itemSelectionChanged({@required Line item}) =
      ItemSelectionChanged;

  factory LinesEvent.selectionReset() = SelectionReset;

  factory LinesEvent.trackedLinesChanged({@required Iterable<Line> lines}) =
      TrackedLinesChanged;

  final _LinesEvent _type;

//ignore: missing_return
  R when<R>(
      {@required R Function(Created) created,
      @required R Function(FilterChanged) filterChanged,
      @required R Function(ItemSelectionChanged) itemSelectionChanged,
      @required R Function(SelectionReset) selectionReset,
      @required R Function(TrackedLinesChanged) trackedLinesChanged}) {
    assert(() {
      if (created == null ||
          filterChanged == null ||
          itemSelectionChanged == null ||
          selectionReset == null ||
          trackedLinesChanged == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.Created:
        return created(this as Created);
      case _LinesEvent.FilterChanged:
        return filterChanged(this as FilterChanged);
      case _LinesEvent.ItemSelectionChanged:
        return itemSelectionChanged(this as ItemSelectionChanged);
      case _LinesEvent.SelectionReset:
        return selectionReset(this as SelectionReset);
      case _LinesEvent.TrackedLinesChanged:
        return trackedLinesChanged(this as TrackedLinesChanged);
    }
  }

//ignore: missing_return
  Future<R> asyncWhen<R>(
      {@required
          FutureOr<R> Function(Created) created,
      @required
          FutureOr<R> Function(FilterChanged) filterChanged,
      @required
          FutureOr<R> Function(ItemSelectionChanged) itemSelectionChanged,
      @required
          FutureOr<R> Function(SelectionReset) selectionReset,
      @required
          FutureOr<R> Function(TrackedLinesChanged) trackedLinesChanged}) {
    assert(() {
      if (created == null ||
          filterChanged == null ||
          itemSelectionChanged == null ||
          selectionReset == null ||
          trackedLinesChanged == null) {
        throw 'check for all possible cases';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.Created:
        return created(this as Created);
      case _LinesEvent.FilterChanged:
        return filterChanged(this as FilterChanged);
      case _LinesEvent.ItemSelectionChanged:
        return itemSelectionChanged(this as ItemSelectionChanged);
      case _LinesEvent.SelectionReset:
        return selectionReset(this as SelectionReset);
      case _LinesEvent.TrackedLinesChanged:
        return trackedLinesChanged(this as TrackedLinesChanged);
    }
  }

  R whenOrElse<R>(
      {R Function(Created) created,
      R Function(FilterChanged) filterChanged,
      R Function(ItemSelectionChanged) itemSelectionChanged,
      R Function(SelectionReset) selectionReset,
      R Function(TrackedLinesChanged) trackedLinesChanged,
      @required R Function(LinesEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.Created:
        if (created == null) break;
        return created(this as Created);
      case _LinesEvent.FilterChanged:
        if (filterChanged == null) break;
        return filterChanged(this as FilterChanged);
      case _LinesEvent.ItemSelectionChanged:
        if (itemSelectionChanged == null) break;
        return itemSelectionChanged(this as ItemSelectionChanged);
      case _LinesEvent.SelectionReset:
        if (selectionReset == null) break;
        return selectionReset(this as SelectionReset);
      case _LinesEvent.TrackedLinesChanged:
        if (trackedLinesChanged == null) break;
        return trackedLinesChanged(this as TrackedLinesChanged);
    }
    return orElse(this);
  }

  Future<R> asyncWhenOrElse<R>(
      {FutureOr<R> Function(Created) created,
      FutureOr<R> Function(FilterChanged) filterChanged,
      FutureOr<R> Function(ItemSelectionChanged) itemSelectionChanged,
      FutureOr<R> Function(SelectionReset) selectionReset,
      FutureOr<R> Function(TrackedLinesChanged) trackedLinesChanged,
      @required FutureOr<R> Function(LinesEvent) orElse}) {
    assert(() {
      if (orElse == null) {
        throw 'Missing orElse case';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.Created:
        if (created == null) break;
        return created(this as Created);
      case _LinesEvent.FilterChanged:
        if (filterChanged == null) break;
        return filterChanged(this as FilterChanged);
      case _LinesEvent.ItemSelectionChanged:
        if (itemSelectionChanged == null) break;
        return itemSelectionChanged(this as ItemSelectionChanged);
      case _LinesEvent.SelectionReset:
        if (selectionReset == null) break;
        return selectionReset(this as SelectionReset);
      case _LinesEvent.TrackedLinesChanged:
        if (trackedLinesChanged == null) break;
        return trackedLinesChanged(this as TrackedLinesChanged);
    }
    return orElse(this);
  }

//ignore: missing_return
  Future<void> whenPartial(
      {FutureOr<void> Function(Created) created,
      FutureOr<void> Function(FilterChanged) filterChanged,
      FutureOr<void> Function(ItemSelectionChanged) itemSelectionChanged,
      FutureOr<void> Function(SelectionReset) selectionReset,
      FutureOr<void> Function(TrackedLinesChanged) trackedLinesChanged}) {
    assert(() {
      if (created == null &&
          filterChanged == null &&
          itemSelectionChanged == null &&
          selectionReset == null &&
          trackedLinesChanged == null) {
        throw 'provide at least one branch';
      }
      return true;
    }());
    switch (this._type) {
      case _LinesEvent.Created:
        if (created == null) break;
        return created(this as Created);
      case _LinesEvent.FilterChanged:
        if (filterChanged == null) break;
        return filterChanged(this as FilterChanged);
      case _LinesEvent.ItemSelectionChanged:
        if (itemSelectionChanged == null) break;
        return itemSelectionChanged(this as ItemSelectionChanged);
      case _LinesEvent.SelectionReset:
        if (selectionReset == null) break;
        return selectionReset(this as SelectionReset);
      case _LinesEvent.TrackedLinesChanged:
        if (trackedLinesChanged == null) break;
        return trackedLinesChanged(this as TrackedLinesChanged);
    }
  }

  @override
  List get props => const [];
}

@immutable
class Created extends LinesEvent {
  const Created({@required this.items}) : super(_LinesEvent.Created);

  final Map<Line, LineState> items;

  @override
  String toString() => 'Created(items:${this.items})';
  @override
  List get props => [items];
}

@immutable
class FilterChanged extends LinesEvent {
  const FilterChanged({@required this.filter})
      : super(_LinesEvent.FilterChanged);

  final String filter;

  @override
  String toString() => 'FilterChanged(filter:${this.filter})';
  @override
  List get props => [filter];
}

@immutable
class ItemSelectionChanged extends LinesEvent {
  const ItemSelectionChanged({@required this.item})
      : super(_LinesEvent.ItemSelectionChanged);

  final Line item;

  @override
  String toString() => 'ItemSelectionChanged(item:${this.item})';
  @override
  List get props => [item];
}

@immutable
class SelectionReset extends LinesEvent {
  const SelectionReset._() : super(_LinesEvent.SelectionReset);

  factory SelectionReset() {
    _instance ??= const SelectionReset._();
    return _instance;
  }

  static SelectionReset _instance;
}

@immutable
class TrackedLinesChanged extends LinesEvent {
  const TrackedLinesChanged({@required this.lines})
      : super(_LinesEvent.TrackedLinesChanged);

  final Iterable<Line> lines;

  @override
  String toString() => 'TrackedLinesChanged(lines:${this.lines})';
  @override
  List get props => [lines];
}
