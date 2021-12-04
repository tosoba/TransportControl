import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as UserLocation;
import 'package:rxdart/src/transformers/start_with.dart';
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
  ) : super(LocationsState.initial()) {
    on<ChangeListOrder>(
      (event, emit) => emit(state.copyWith(listOrder: event.order)),
    );
    on<UpdateLocations>(
      (event, emit) => emit(state.copyWith(locations: event.locations)),
    );
    on<NameFilterChanged>(
      (event, emit) => emit(state.copyWith(nameFilter: event.filter)),
    );

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

  Stream<FilteredLocationsResult> get filteredLocationsStream {
    return stream.startWith(state).map((state) {
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
    }).distinct();
  }

  Stream<LocationsListOrder> get listOrderStream {
    return stream
        .map((state) => state.listOrder)
        .startWith(state.listOrder)
        .distinct();
  }

  Stream<List<LocationsListOrder>> get listOrdersStream {
    return stream
        .map((state) => state.listOrder)
        .startWith(state.listOrder)
        .map(
          (listOrder) => const [
            const BySavedTimestampWrapper(const BySavedTimestamp()),
            const ByLastSearchedWrapper(const ByLastSearched()),
            const ByTimesSearchedWrapper(const ByTimesSearched())
          ].where((value) => value != listOrder).toList(),
        )
        .distinct();
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
