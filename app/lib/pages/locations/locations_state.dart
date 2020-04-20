import 'package:flutter/material.dart';
import 'package:transport_control/model/location.dart';

class LocationsState {
  final List<Location> locations;
  final String nameFilter;
  final LocationsListOrder listOrder;

  LocationsState._({
    @required this.locations,
    @required this.nameFilter,
    @required this.listOrder,
  });

  LocationsState.initial()
      : locations = [],
        nameFilter = null,
        listOrder = LocationsListOrder.lastSearched;

  LocationsState copyWith({
    List<Location> locations,
    String nameFilter,
    LocationsListOrder listOrder,
  }) {
    return LocationsState._(
      locations: locations ?? this.locations,
      nameFilter: nameFilter ?? this.nameFilter,
      listOrder: listOrder ?? this.listOrder,
    );
  }
}

enum LocationsListOrder { lastSearched, timesSearched }

class FilteredLocationsResult {
  final List<Location> locations;
  final bool anyLocationsSaved;

  FilteredLocationsResult({
    @required this.locations,
    @required this.anyLocationsSaved,
  });
}
