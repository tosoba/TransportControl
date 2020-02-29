import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/factories/triplet_factory.dart';
import 'package:sealed_unions/implementations/union_3_impl.dart';
import 'package:sealed_unions/union_3.dart';
import 'package:transport_control/model/line.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:search_app_bar/searcher.dart';

class LineListItem {
  final Line line;
  final bool selected = false;

  LineListItem(this.line);
}

class LinesState {
  final List<LineListItem> items;
  final List<LineListItem> filteredItems;

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

  factory _LinesEvent.created(List<LineListItem> items) =>
      _LinesEvent._(_factory.first(_Created(items)));
  factory _LinesEvent.itemsFiltered(List<LineListItem> items) =>
      _LinesEvent._(_factory.second(_ItemsFiltered(items)));
  factory _LinesEvent.itemSelectionChanged(LineListItem item) =>
      _LinesEvent._(_factory.third(_ItemSelectionChanged(item)));
}

class _Created {
  final List<LineListItem> items;

  _Created(this.items);
}

class _ItemsFiltered {
  final List<LineListItem> items;

  _ItemsFiltered(this.items);
}

class _ItemSelectionChanged {
  final LineListItem item;

  _ItemSelectionChanged(this.item);
}

class LinesBloc extends Bloc<_LinesEvent, LinesState>
    implements Searcher<LineListItem> {
  @override
  LinesState get initialState => LinesState.empty();

  LinesBloc() {
    rootBundle.loadString('assets/lines.json').then((jsonString) {
      final lineItems = (jsonDecode(jsonString) as List)
          .map((lineJson) => LineListItem(Line.fromJson(lineJson)))
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
  List<LineListItem> get data => state.items.toList();

  @override
  Function(List<LineListItem>) get onDataFiltered =>
      (List<LineListItem> filtered) => add(_LinesEvent.itemsFiltered(filtered));
}
