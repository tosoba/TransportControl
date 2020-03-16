import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/factories/quartet_factory.dart';
import 'package:sealed_unions/implementations/union_4_impl.dart';
import 'package:sealed_unions/sealed_unions.dart';
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
      final lineItems = Map.fromIterable(
        jsonDecode(jsonString) as List,
        key: (lineJson) => Line.fromJson(lineJson),
        value: (_) => false,
      );
      add(_LinesEvent.created(lineItems));
    });
  }

  @override
  Stream<LinesState> mapEventToState(_LinesEvent event) async* {
    yield event.join(
      (created) => LinesState(items: created.items, filter: null),
      (filterChange) =>
          LinesState(items: state.items, filter: filterChange.filter),
      (selectionChange) {
        final updatedItems = Map.of(state.items);
        updatedItems[selectionChange.item] = selectionChange.selected;
        return LinesState(items: updatedItems, filter: state.filter);
      },
      (_) {
        final updatedItems = Map.of(state.items);
        updatedItems.forEach((key, value) => updatedItems[key] = false);
        return LinesState(items: updatedItems, filter: state.filter);
      },
    );
  }

  @override
  List<MapEntry<Line, bool>> get data => state.items.entries.toList();

  @override
  Function(String) get filterChanged =>
      (filter) => add(_LinesEvent.filterChanged(filter));

  Stream<List<MapEntry<Line, bool>>> get filteredItemsStream =>
      map((state) => state.filter == null
          ? state.items.entries.toList()
          : state.items.entries
              .where((entry) => entry.key.symbol
                  .toLowerCase()
                  .contains(state.filter.trim().toLowerCase()))
              .toList());

  itemSelectionChanged(Line item, bool selected) =>
      add(_LinesEvent.itemSelectionChanged(item, selected));

  selectionReset() => add(_LinesEvent.selectionReset());
}
