part of 'package:transport_control/pages/lines/lines_bloc.dart';

class _LinesEvent
    extends Union3Impl<_Created, _ItemsFiltered, _ItemSelectionChanged> {
  static final Triplet<_Created, _ItemsFiltered, _ItemSelectionChanged>
      _factory =
      const Triplet<_Created, _ItemsFiltered, _ItemSelectionChanged>();

  _LinesEvent._(Union3<_Created, _ItemsFiltered, _ItemSelectionChanged> union)
      : super(union);

  factory _LinesEvent.created(Map<Line, bool> items) =>
      _LinesEvent._(_factory.first(_Created(items)));
  factory _LinesEvent.itemsFiltered(Map<Line, bool> items) =>
      _LinesEvent._(_factory.second(_ItemsFiltered(items)));
  factory _LinesEvent.itemSelectionChanged(Line item, bool selected) =>
      _LinesEvent._(_factory.third(_ItemSelectionChanged(item, selected)));
}

class _Created {
  final Map<Line, bool> items;

  _Created(this.items);
}

class _ItemsFiltered {
  final Map<Line, bool> items;

  _ItemsFiltered(this.items);
}

class _ItemSelectionChanged {
  final Line item;
  final bool selected;

  _ItemSelectionChanged(this.item, this.selected);
}
