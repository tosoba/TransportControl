import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:transport_control/api/vehicles_api.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/line.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/model/vehicles_response.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/res/strings.dart';
import 'package:transport_control/util/model_util.dart';

@RegisterAs(VehiclesRepo, env: Env.dev)
@singleton
class VehiclesRepoImpl extends VehiclesRepo {
  final VehiclesApi _api;

  VehiclesRepoImpl(this._api);

  static final Duration _timeoutDuration = Duration(seconds: 3);

  @override
  Future<Result<List<Vehicle>>> loadVehiclesOfLines(Iterable<Line> lines) {
    if (lines == null || lines.isEmpty) {
      return Future.value(
        Result.failure(error: ArgumentError(ErrorMessages.NO_LINES)),
      );
    } else if (lines.length == 1) {
      return _api
          .fetchVehicles(
            type: lines.first.type,
            line: lines.first.symbol,
          )
          .timeout(_timeoutDuration)
          .then((response) => Result.success(data: response.vehicles))
          .catchError((error) => Result<List<Vehicle>>.failure(error: error));
    } else {
      final lineSymbols = lines.map((line) => line.symbol).toSet();
      return _loadVehiclesOfTypesUsing<Line>(lines, (line) => line.type)
          .then(
            (responses) => Result.success(
              data: responses.filterVehicles(
                (vehicle) =>
                    vehicle.isValid && lineSymbols.contains(vehicle.symbol),
              ),
            ),
          )
          .catchError((error) => Result<List<Vehicle>>.failure(error: error));
    }
  }

  @override
  Future<Result<List<Vehicle>>> loadVehicles(Iterable<Vehicle> vehicles) {
    final vehicleNumbers = vehicles.map((vehicle) => vehicle.number).toSet();
    return _loadVehiclesOfTypesUsing<Vehicle>(
            vehicles, (vehicle) => vehicle.type)
        .then(
          (responses) => Result.success(
            data: responses.filterVehicles(
              (vehicle) =>
                  vehicle.isValid && vehicleNumbers.contains(vehicle.number),
            ),
          ),
        )
        .catchError((error) => Result<List<Vehicle>>.failure(error: error));
  }

  @override
  Future<Result<List<Vehicle>>> loadVehiclesInArea({
    double southWestLat,
    double southWestLon,
    double northEastLat,
    double northEastLon,
    int type,
  }) {
    throw UnimplementedError();
  }

  Future<List<VehiclesResponse>> _loadVehiclesOfTypesUsing<T>(
    Iterable<T> list,
    int Function(T) typeGetter,
  ) {
    return Future.wait(
      list.map(typeGetter).toSet().map(
          (type) => _api.fetchVehicles(type: type).timeout(_timeoutDuration)),
      eagerError: true,
    );
  }
}

extension _VehicleResponsesExt on List<VehiclesResponse> {
  List<Vehicle> filterVehicles(bool Function(Vehicle) filter) {
    return map(
      (response) => response.vehicles.where(filter).toList(),
    ).fold<List<Vehicle>>(
      [],
      (previousValue, element) => previousValue + element,
    );
  }
}
