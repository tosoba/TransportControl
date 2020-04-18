import 'package:flutter/material.dart';
import 'package:transport_control/model/location.dart';
import 'package:transport_control/pages/map_location/map_location_page_mode.dart';
import 'package:transport_control/pages/map_location/map_location_page_result_action.dart';

class MapLocationPageResult {
  final Location location;
  final MapLocationPageMode mode;
  final MapLocationPageResultAction action;

  MapLocationPageResult({
    @required this.location,
    @required this.mode,
    @required this.action,
  });
}
