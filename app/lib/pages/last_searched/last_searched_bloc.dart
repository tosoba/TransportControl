import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/pages/last_searched/last_searched_event.dart';
import 'package:transport_control/repo/last_searched_repo.dart';

class LastSearchedBloc extends Bloc<LastSearchedEvent, List<SearchedItem>> {
  final LastSearchedRepo _repo;

  final List<StreamSubscription> _subscriptions = [];

  LastSearchedBloc(this._repo) {
    _subscriptions.add(
      _repo.getLastSearchedItemsStream().listen((items) {
        add(LastSearchedEvent.updateItems(items: items));
      }),
    );
  }

  @override
  Future<void> close() async {
    await Future.wait(
      _subscriptions.map((subscription) => subscription.cancel()),
    );
    return super.close();
  }

  @override
  List<SearchedItem> get initialState => [];

  @override
  Stream<List<SearchedItem>> mapEventToState(LastSearchedEvent event) async* {
    yield event.when(updateItems: (updateEvt) => updateEvt.items);
  }
}
