import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_event.dart';
import 'package:transport_control/pages/locations/locations_state.dart';
import 'package:transport_control/repo/locations_repo.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final LocationsRepo _repo;

  StreamSubscription<List<Location>> _locationUpdatesSubscription;

  LocationsBloc(this._repo) {
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
    );
  }

  Stream<List<Location>> get locationsStream {
    return map((state) => state.locations..orderBy(state.listOrder));
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
