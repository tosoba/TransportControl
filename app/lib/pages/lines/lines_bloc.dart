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
  List<LineListItemState> get data => state.items;

  @override
  Function(List<LineListItemState>) get onDataFiltered =>
      (List<LineListItemState> filtered) =>
          add(_LinesEvent.itemsFiltered(filtered));
}
