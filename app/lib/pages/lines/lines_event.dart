part of 'package:transport_control/pages/lines/lines_bloc.dart';

class _LinesEvent extends Union5Impl<_Created, _FilterChanged,
    _ItemSelectionChanged, _SelectionReset, _TrackedLinesChanged> {
  static final Quintet<_Created, _FilterChanged, _ItemSelectionChanged,
          _SelectionReset, _TrackedLinesChanged> _factory =
      const Quintet<_Created, _FilterChanged, _ItemSelectionChanged,
          _SelectionReset, _TrackedLinesChanged>();

  _LinesEvent._(
      Union5<_Created, _FilterChanged, _ItemSelectionChanged, _SelectionReset,
              _TrackedLinesChanged>
          union)
      : super(union);

  factory _LinesEvent.created(Map<Line, LineState> items) =>
      _LinesEvent._(_factory.first(_Created(items)));
  factory _LinesEvent.filterChanged(String filter) =>
      _LinesEvent._(_factory.second(_FilterChanged(filter)));
  factory _LinesEvent.itemSelectionChanged(Line item) =>
      _LinesEvent._(_factory.third(_ItemSelectionChanged(item)));
  factory _LinesEvent.selectionReset() =>
      _LinesEvent._(_factory.fourth(_SelectionReset()));
  factory _LinesEvent.trackedLinesChanged(Set<Line> trackedLines) =>
      _LinesEvent._(_factory.fifth(_TrackedLinesChanged(trackedLines)));
}

class _Created {
  final Map<Line, LineState> items;

  _Created(this.items);
}

class _FilterChanged {
  final String filter;

  _FilterChanged(this.filter);
}

class _ItemSelectionChanged {
  final Line item;

  _ItemSelectionChanged(this.item);
}

class _SelectionReset {}

class _TrackedLinesChanged {
  final Set<Line> trackedLines;

  _TrackedLinesChanged(this.trackedLines);
}
