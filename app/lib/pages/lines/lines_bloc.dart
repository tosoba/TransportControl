import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_unions/factories/triplet_factory.dart';
import 'package:sealed_unions/implementations/union_3_impl.dart';
import 'package:sealed_unions/union_3.dart';
import 'package:transport_control/model/line.dart';
import 'package:flutter/services.dart' show rootBundle;

class LineListItem {
  final Line line;
  final bool selected = false;

  LineListItem(this.line);
}

class LinesState {
  final Set<LineListItem> items;
  final String filter = '';

  LinesState(this.items);
}

class _LinesEvent
    extends Union3Impl<_Created, _FilterUpdated, _ItemSelectionChanged> {
  static final Triplet<_Created, _FilterUpdated, _ItemSelectionChanged>
      _factory =
      const Triplet<_Created, _FilterUpdated, _ItemSelectionChanged>();

  _LinesEvent._(Union3<_Created, _FilterUpdated, _ItemSelectionChanged> union)
      : super(union);

  factory _LinesEvent.created() => _LinesEvent._(_factory.first(_Created()));
  factory _LinesEvent.filterUpdated(String filter) =>
      _LinesEvent._(_factory.second(_FilterUpdated(filter)));
  factory _LinesEvent.itemSelectionChanged(LineListItem item) =>
      _LinesEvent._(_factory.third(_ItemSelectionChanged(item)));
}

class _Created {}

class _FilterUpdated {
  final String filter;

  _FilterUpdated(this.filter);
}

class _ItemSelectionChanged {
  final LineListItem item;

  _ItemSelectionChanged(this.item);
}

class LinesBloc extends Bloc<_LinesEvent, LinesState> {
  @override
  LinesState get initialState => null;

  LinesBloc() {
    rootBundle.loadString('assets/lines.json').then((jsonString) {
      (jsonDecode(jsonString) as List)
          .map((lineJson) => LineListItem(Line.fromJson(lineJson)))
          .toList();
    });
  }

  @override
  Stream<LinesState> mapEventToState(_LinesEvent event) async* {
    event.join((created) {}, (filterUpdate) {}, (selectionChange) {});
  }
}
