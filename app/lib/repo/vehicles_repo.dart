import 'package:flutter/material.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';

abstract class VehiclesRepo {
  Future<Result<List<Vehicle>>> loadVehiclesInArea({
    @required double southWestLat,
    @required double southWestLon,
    @required double northEastLat,
    @required double northEastLon,
    int type,
  });

  Future<Result<List<Vehicle>>> loadVehiclesOfLines(Iterable<Line> lines);

  Future<Result<List<Vehicle>>> loadVehicles(Iterable<Vehicle> vehicles);
}
