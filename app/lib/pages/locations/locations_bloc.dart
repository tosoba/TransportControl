import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as UserLocation;
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_event.dart';
import 'package:transport_control/pages/locations/locations_list_order.dart';
import 'package:transport_control/pages/locations/locations_signal.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/util/location_util.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final LocationsRepo _repo;
  final Sink<Location> _loadVehiclesInLocationSink;
  final Sink<LatLng> _loadVehiclesNearbyUserLocationSink;

  final List<StreamSubscription> _subscriptions = [];

  final StreamController<LocationsSignal> _signals =
      StreamController.broadcast();
  Stream<LocationsSignal> get signals => _signals.stream;

  LocationsBloc(
    this._repo,
    this._loadVehiclesInLocationSink,
    this._loadVehiclesNearbyUserLocationSink,
  ) {
    _subscriptions
      ..add(
        _repo.favouriteLocationsStream.listen(
          (locations) =>
              add(LocationsEvent.updateLocations(locations: locations)),
        ),
      );
  }

  @override
  Future<void> close() async {
    await Future.wait([
      ..._subscriptions.map((subscription) => subscription.cancel()),
      _signals.close(),
    ]);
    return super.close();
  }

  @override
  LocationsState get initialState => LocationsState.initial();

  @override
  Stream<LocationsState> mapEventToState(LocationsEvent event) async* {
    yield event.when(
      changeListOrder: (evt) => state.copyWith(listOrder: evt.order),
      updateLocations: (evt) => state.copyWith(locations: evt.locations),
      nameFilterChanged: (evt) => state.copyWith(nameFilter: evt.filter),
    );
  }

  Stream<FilteredLocationsResult> get filteredLocationsStream {
    return map((state) {
      final filter = state.nameFilter == null
          ? (Location location) => true
          : (Location location) => location.name
              .toLowerCase()
              .contains(state.nameFilter.trim().toLowerCase());
      return FilteredLocationsResult(
        locations: state.locations.where(filter).toList()
          ..orderBy(state.listOrder),
        anyLocationsSaved: state.locations.isNotEmpty,
        nameFilter: state.nameFilter,
      );
    });
  }

  Stream<LocationsListOrder> get listOrderStream {
    return map((state) => state.listOrder);
  }

  Stream<List<LocationsListOrder>> get listOrdersStream {
    return map(
      (state) => const [
        const BySavedTimestampWrapper(const BySavedTimestamp()),
        const ByLastSearchedWrapper(const ByLastSearched()),
        const ByTimesSearchedWrapper(const ByTimesSearched())
      ].where((value) => value != state.listOrder).toList(),
    );
  }

  void nameFilterChanged(String filter) {
    add(LocationsEvent.nameFilterChanged(filter: filter));
  }

  void listOrderChanged(LocationsListOrder order) {
    add(LocationsEvent.changeListOrder(order: order));
  }

  void loadVehiclesInLocation(Location location) {
    final updatedLocation = location.copyWith(lastSearched: DateTime.now());
    updateLocation(updatedLocation);
    _loadVehiclesInLocationSink.add(updatedLocation);
  }

  void loadVehiclesNearbyUserLocation() async {
    _signals.add(LocationsSignal.loading(message: 'Loading location...'));
    final locationResult = await UserLocation.Location().tryGet();
    locationResult.asyncWhenOrElse(
      success: (result) async {
        final locationData = result.data;
        if (locationData.latitude == null || locationData.longitude == null) {
          _signals.add(
            LocationsSignal.loadingError(message: 'Unable to load location.'),
          );
          return;
        }

        _loadVehiclesNearbyUserLocationSink.add(
          LatLng(result.data.latitude, result.data.longitude),
        );
        _signals.add(LocationsSignal.loadedSuccessfully());
      },
      orElse: (result) {
        _signals.add(
          LocationsSignal.loadingError(message: 'Unable to load location.'),
        );
      },
    );
  }

  void saveLocation(Location location) {
    _repo.insertLocation(location);
  }

  void updateLocation(Location location) {
    _repo.updateLocation(location);
  }

  void deleteLocation(Location location) {
    _repo.deleteLocation(location);
  }
}

extension _LocationsListExt on List<Location> {
  void orderBy(LocationsListOrder order) {
    order.when(
      savedTimestamp: (_) {
        sort((loc1, loc2) => loc2.savedAt.compareTo(loc1.savedAt));
      },
      lastSearched: (_) {
        sort(
          (loc1, loc2) {
            return (loc2.lastSearched ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(loc1.lastSearched ??
                    DateTime.fromMillisecondsSinceEpoch(0));
          },
        );
      },
      timesSearched: (_) {
        sort((loc1, loc2) {
          return (loc2.timesSearched ?? 0).compareTo(loc1.timesSearched ?? 0);
        });
      },
    );
  }
}
