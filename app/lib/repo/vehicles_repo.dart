import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';

abstract class VehiclesRepo {
  Future<Result<List<Vehicle>>> loadVehiclesInBounds(
    LatLngBounds bounds, {
    int type,
  });

  Future<Result<List<Vehicle>>> loadVehiclesNearby(
    LatLng position, {
    @required int radiusInMeters,
    int type,
  });

  Future<Result<List<Vehicle>>> loadVehiclesOfLines(Iterable<Line> lines);

  Future<Result<List<Vehicle>>> loadUpdatedVehicles(Iterable<Vehicle> vehicles);
}
