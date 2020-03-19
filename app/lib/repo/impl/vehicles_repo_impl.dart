import 'package:injectable/injectable.dart';
import 'package:transport_control/api/vehicles_api.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/model/vehicles_response.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/res/strings.dart';
import 'package:transport_control/util/future_ext.dart';
import 'package:transport_control/util/vehicle_ext.dart';

@RegisterAs(VehiclesRepo, env: Env.dev)
@singleton
class VehiclesRepoImpl extends VehiclesRepo {
  final VehiclesApi _api;

  VehiclesRepoImpl(this._api);

  static final Duration _timeoutDuration = Duration(seconds: 3);

  @override
  Future<Result<List<Vehicle>>> loadVehiclesOfLines(
    Iterable<String> lines, {
    int type,
  }) {
    if (lines == null || lines.isEmpty) {
      return Future.value(Result.error(ArgumentError(ErrorMessages.NO_LINES)));
    } else if (lines.length == 1) {
      return _api
          .fetchVehicles(type: type, line: lines.first)
          .timeout(_timeoutDuration)
          .thenTransformAndWrapIntoResult(
            transform: (VehiclesResponse response) => response.vehicles,
          );
    } else {
      return _api
          .fetchVehicles(type: type)
          .timeout(_timeoutDuration)
          .thenTransformAndWrapIntoResult(
            transform: (VehiclesResponse response) => response.vehicles
                .where(
                  (Vehicle vehicle) =>
                      vehicle.isValid && lines.contains(vehicle.symbol),
                )
                .toList(),
          );
    }
  }

  @override
  Future<Result<Iterable<Vehicle>>> loadVehiclesInArea({
    double southWestLat,
    double southWestLon,
    double northEastLat,
    double northEastLon,
    int type,
  }) {
    throw UnimplementedError();
  }
}
