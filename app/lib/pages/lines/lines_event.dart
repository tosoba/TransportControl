part of 'package:transport_control/pages/lines/lines_bloc.dart';

class _LinesEvent
    extends Union3Impl<_Created, _FilterChanged, _ItemSelectionChanged> {
  static final Triplet<_Created, _FilterChanged, _ItemSelectionChanged>
      _factory =
      const Triplet<_Created, _FilterChanged, _ItemSelectionChanged>();

  _LinesEvent._(Union3<_Created, _FilterChanged, _ItemSelectionChanged> union)
      : super(union);

  factory _LinesEvent.created(Map<Line, bool> items) =>
      _LinesEvent._(_factory.first(_Created(items)));
  factory _LinesEvent.filterChanged(String filter) =>
      _LinesEvent._(_factory.second(_FilterChanged(filter)));
  factory _LinesEvent.itemSelectionChanged(Line item, bool selected) =>
      _LinesEvent._(_factory.third(_ItemSelectionChanged(item, selected)));
}

class _Created {
  final Map<Line, bool> items;

  _Created(this.items);
}

class _FilterChanged {
  final String filter;

  _FilterChanged(this.filter);
}

class _ItemSelectionChanged {
  final Line item;
  final bool selected;

  _ItemSelectionChanged(this.item, this.selected);
}
