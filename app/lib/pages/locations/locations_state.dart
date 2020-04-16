import 'package:flutter/material.dart';
import 'package:transport_control/model/location.dart';

class LocationsState {
  final List<Location> locations;
  final String filter;
  final LocationsListOrder listOrder;

  LocationsState._({
    @required this.locations,
    @required this.filter,
    @required this.listOrder,
  });

  LocationsState.initial()
      : locations = [],
        filter = null,
        listOrder = LocationsListOrder.lastSearched;

  LocationsState copyWith({
    List<Location> locations,
    String filter,
    LocationsListOrder listOrder,
  }) {
    return LocationsState._(
      locations: locations ?? this.locations,
      filter: filter ?? this.filter,
      listOrder: listOrder ?? this.listOrder,
    );
  }
}

enum LocationsListOrder { lastSearched, timesSearched }
