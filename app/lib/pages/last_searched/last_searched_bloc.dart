import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/model/searched_item.dart';
import 'package:transport_control/pages/last_searched/last_searched_event.dart';
import 'package:transport_control/pages/map/map_vehicle_source.dart';
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

  Stream<SearchedItems> notLoadedLastSearchedItemsDataStream({
    @required Stream<Set<MapVehicleSource>> loadedVehicleSourcesStream,
    int limit = 10,
  }) {
    return combineLatest(
      loadedVehicleSourcesStream,
      (items, Set<MapVehicleSource> sources) {
        final lineSymbols = <String>{};
        final locationIds = <int>{};
        sources.forEach((source) {
          source.whenPartial(
            ofLine: (lineSource) {
              lineSymbols.add(lineSource.line.symbol);
            },
            nearbyLocation: (locationSource) {
              locationIds.add(locationSource.location.id);
            },
          );
        });

        final filteredItems = items.where(
          (item) => item.when(
            lineItem: (lineItem) => !lineSymbols.contains(lineItem.line.symbol),
            locationItem: (locationItem) => !locationIds.contains(
              locationItem.location.id,
            ),
          ),
        );
        return filteredItems.length > limit
            ? SearchedItems(
                mostRecentItems: filteredItems.take(limit).toList(),
                moreAvailable: true,
              )
            : SearchedItems(
                mostRecentItems: filteredItems.toList(),
                moreAvailable: false,
              );
      },
    );
  }
}

class SearchedItems {
  final List<SearchedItem> mostRecentItems;
  final bool moreAvailable;

  SearchedItems({
    @required this.mostRecentItems,
    @required this.moreAvailable,
  });

  SearchedItems filterByType<T extends SearchedItem>() {
    return SearchedItems(
      mostRecentItems: mostRecentItems.where((item) => item is T).toList(),
      moreAvailable: moreAvailable,
    );
  }
}
