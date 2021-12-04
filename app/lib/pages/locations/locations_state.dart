import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/locations/locations_list_order.dart';

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
        listOrder = LocationsListOrder.lastSearched(const ByLastSearched());

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

class FilteredLocationsResult extends Equatable {
  final List<Location> locations;
  final bool anyLocationsSaved;
  final String nameFilter;

  FilteredLocationsResult({
    @required this.locations,
    @required this.anyLocationsSaved,
    @required this.nameFilter,
  });

  @override
  List<Object> get props => [locations, anyLocationsSaved, nameFilter];
}
