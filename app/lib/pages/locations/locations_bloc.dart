import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as UserLocation;
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_event.dart';
import 'package:transport_control/pages/locations/locations_list_order.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/repo/locations_repo.dart';
import 'package:transport_control/util/location_util.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final LocationsRepo _repo;
  final void Function(Location) saveLocation;
  final void Function(Location) updateLocation;
  final void Function(Location) deleteLocation;
  final void Function(LatLngBounds) _loadVehiclesInBounds;
  final void Function(
    LatLng position, {
    @required double radiusInMeters,
  }) _loadVehiclesNearby;

  StreamSubscription<List<Location>> _locationUpdatesSubscription;

  LocationsBloc(
    this._repo,
    this._loadVehiclesInBounds,
    this._loadVehiclesNearby, {
    @required this.saveLocation,
    @required this.updateLocation,
    @required this.deleteLocation,
  }) {
    _locationUpdatesSubscription = _repo.favouriteLocationsStream.listen(
      (locations) => add(LocationsEvent.updateLocations(locations: locations)),
    );
  }

  @override
  Future<void> close() async {
    await _locationUpdatesSubscription.cancel();
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

  Future<bool> loadVehiclesInBounds(LatLngBounds bounds) async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      return false;
    }
    _loadVehiclesInBounds(bounds);
    return true;
  }

  //TODO: return a result enum instead of bool for showing info to user
  Future<bool> loadVehiclesNearbyUserLocation() async {
    final locationResult = await UserLocation.Location().tryGet();
    return locationResult.asyncWhenOrElse(
      success: (result) async {
        final locationData = result.data;
        if (locationData.latitude == null || locationData.longitude == null) {
          return false;
        }
        if (await Connectivity().checkConnectivity() ==
            ConnectivityResult.none) {
          return false;
        }
        _loadVehiclesNearby(
          LatLng(result.data.latitude, result.data.longitude),
          radiusInMeters: 1000, //TODO: move this to settings
        );
        return true;
      },
      orElse: (_) => false,
    );
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
