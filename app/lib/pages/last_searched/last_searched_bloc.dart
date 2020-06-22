import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/location.dart';
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

  Stream<SearchedItemsData> notLoadedLastSearchedItemsDataStream({
    @required Stream<Set<MapVehicleSource>> loadedVehicleSourcesStream,
    int limit = 10,
  }) {
    return combineLatest(
      loadedVehicleSourcesStream,
      (items, Set<MapVehicleSource> sources) {
        final lineSources = <Line>{};
        final locationSources = <Location>{};
        sources.forEach((source) {
          source.whenPartial(
            ofLine: (lineSource) {
              lineSources.add(lineSource.line);
            },
            nearbyLocation: (locationSource) {
              locationSources.add(locationSource.location);
            },
          );
        });

        final filteredItems = items.where(
          (item) => item.when(
            lineItem: (lineItem) {
              return !lineSources.contains(lineItem.line);
            },
            locationItem: (locationItem) {
              return !locationSources.contains(locationItem.location);
            },
          ),
        );
        return filteredItems.length > limit
            ? SearchedItemsData(
                mostRecentItems: filteredItems.take(limit).toList(),
                showMoreAvailable: true,
              )
            : SearchedItemsData(
                mostRecentItems: filteredItems.toList(),
                showMoreAvailable: false,
              );
      },
    );
  }
}

class SearchedItemsData {
  final List<SearchedItem> mostRecentItems;
  final bool showMoreAvailable;

  SearchedItemsData({
    @required this.mostRecentItems,
    @required this.showMoreAvailable,
  });
}
