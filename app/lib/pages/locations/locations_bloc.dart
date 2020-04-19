import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_event.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/repo/locations_repo.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final LocationsRepo _repo;
  final void Function(Location) saveLocation;
  final void Function(Location) updateLocation;
  final void Function(Location) deleteLocation;
  final void Function(LatLngBounds) loadVehiclesInBounds;

  StreamSubscription<List<Location>> _locationUpdatesSubscription;

  LocationsBloc(
    this._repo, {
    @required this.saveLocation,
    @required this.updateLocation,
    @required this.deleteLocation,
    @required this.loadVehiclesInBounds,
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

  Stream<List<Location>> get filteredLocationsStream {
    return map((state) {
      final filter = state.nameFilter == null
          ? (Location location) => true
          : (Location location) => location.name
              .toLowerCase()
              .contains(state.nameFilter.trim().toLowerCase());
      return state.locations.where(filter).toList()..orderBy(state.listOrder);
    });
  }

  void nameFilterChanged(String filter) {
    add(LocationsEvent.nameFilterChanged(filter: filter));
  }
}

extension _LocationsListExt on List<Location> {
  void orderBy(LocationsListOrder order) {
    if (order == LocationsListOrder.lastSearched) {
      sort((loc1, loc2) => loc1.lastSearched.compareTo(loc2.lastSearched));
    } else {
      sort((loc1, loc2) => loc1.timesSearched.compareTo(loc2.timesSearched));
    }
  }
}
