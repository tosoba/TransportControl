import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/factories/triplet_factory.dart';
import 'package:sealed_unions/implementations/union_3_impl.dart';
import 'package:sealed_unions/union_3.dart';
import 'package:transport_control/model/line.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:search_app_bar/searcher.dart';

class LineListItemState {
  final Line line;
  final bool selected = false;

  LineListItemState(this.line);
}

class LinesState {
  final List<LineListItemState> items;
  final List<LineListItemState> filteredItems;

  LinesState({@required this.items, @required this.filteredItems});

  factory LinesState.empty() =>
      LinesState(items: List(), filteredItems: List());
}

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

class LinesBloc extends Bloc<_LinesEvent, LinesState>
    implements Searcher<LineListItemState> {
  @override
  LinesState get initialState => LinesState.empty();

  LinesBloc() {
    rootBundle.loadString('assets/lines.json').then((jsonString) {
      final lineItems = (jsonDecode(jsonString) as List)
          .map((lineJson) => LineListItemState(Line.fromJson(lineJson)))
          .toList();
      add(_LinesEvent.created(lineItems));
    });
  }

  @override
  Stream<LinesState> mapEventToState(_LinesEvent event) async* {
    yield event.join(
        (created) =>
            LinesState(items: created.items, filteredItems: created.items),
        (filtered) =>
            LinesState(items: state.items, filteredItems: filtered.items),
        (selectionChange) => state);
  }

  @override
  List<LineListItemState> get data => state.items.toList();

  @override
  Function(List<LineListItemState>) get onDataFiltered =>
      (List<LineListItemState> filtered) =>
          add(_LinesEvent.itemsFiltered(filtered));
}
