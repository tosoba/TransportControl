import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/implementations/union_3_impl.dart';
import 'package:sealed_unions/factories/triplet_factory.dart';
import 'package:sealed_unions/union_3.dart';
import 'package:search_app_bar/searcher.dart';
import 'package:transport_control/model/line.dart';

part 'package:transport_control/pages/lines/lines_state.dart';
part 'package:transport_control/pages/lines/lines_event.dart';

class LinesBloc extends Bloc<_LinesEvent, LinesState>
    implements Searcher<MapEntry<Line, bool>> {
  @override
  LinesState get initialState => LinesState.empty();

  LinesBloc() {
    rootBundle.loadString('assets/lines.json').then((jsonString) {
      final lineItems = Map.fromIterable(jsonDecode(jsonString) as List,
          key: (lineJson) => Line.fromJson(lineJson), value: (_) => false);
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
        (selectionChange) {
      final updatedItems = Map.of(state.items);
      updatedItems[selectionChange.item] = selectionChange.selected;
      final updatedFilteredItems = Map.of(state.filteredItems);
      updatedFilteredItems[selectionChange.item] = selectionChange.selected;
      return LinesState(
          items: updatedItems, filteredItems: updatedFilteredItems);
    });
  }

  @override
  List<MapEntry<Line, bool>> get data => state.items.entries.toList();

  @override
  Function(List<MapEntry<Line, bool>>) get onDataFiltered =>
      (List<MapEntry<Line, bool>> filtered) =>
          add(_LinesEvent.itemsFiltered(Map.fromEntries(filtered)));

  void itemSelectionChanged(Line item, bool selected) {
    add(_LinesEvent.itemSelectionChanged(item, selected));
  }
}
