part of 'package:transport_control/pages/lines/lines_bloc.dart';

class _LinesEvent
    extends Union3Impl<_Created, _ItemsFiltered, _ItemSelectionChanged> {
  static final Triplet<_Created, _ItemsFiltered, _ItemSelectionChanged>
      _factory =
      const Triplet<_Created, _ItemsFiltered, _ItemSelectionChanged>();

  _LinesEvent._(Union3<_Created, _ItemsFiltered, _ItemSelectionChanged> union)
      : super(union);

  factory _LinesEvent.created(List<LineListItemState> items) =>
      _LinesEvent._(_factory.first(_Created(items)));
  factory _LinesEvent.itemsFiltered(List<LineListItemState> items) =>
      _LinesEvent._(_factory.second(_ItemsFiltered(items)));
  factory _LinesEvent.itemSelectionChanged(LineListItemState item) =>
      _LinesEvent._(_factory.third(_ItemSelectionChanged(item)));
}

class _Created {
  final List<LineListItemState> items;

  _Created(this.items);
}

class _ItemsFiltered {
  final List<LineListItemState> items;

  _ItemsFiltered(this.items);
}

class _ItemSelectionChanged {
  final LineListItemState item;

  _ItemSelectionChanged(this.item);
}
