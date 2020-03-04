import 'package:injectable/injectable.dart';
import 'package:transport_control/api/vehicles_api.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/repo/vehicles_repo.dart';
import 'package:transport_control/res/strings.dart';
import 'package:transport_control/util/future_ext.dart';
import 'package:transport_control/util/vehicle_ext.dart';

@RegisterAs(VehiclesRepo, env: Env.dev)
@singleton
class VehiclesRepoImpl extends VehiclesRepo {
  final VehiclesApi _api;

  VehiclesRepoImpl(this._api);

  @override
  Future<Result<List<Vehicle>>> loadVehiclesOfLines({
    List<String> lines,
    int type,
  }) {
    if (lines == null || lines.isEmpty) {
      return Future.value(Result.error(ArgumentError(ErrorMessages.NO_LINES)));
    } else if (lines.length == 1) {
      return _api.fetchVehicles(type: type, line: lines.first).vehiclesResult;
    } else {
      return _api
          .fetchVehicles(type: type)
          .then((response) => response.vehicles
              .where((vehicle) =>
                  vehicle.isValid && lines.contains(vehicle.symbol))
              .toList())
          .result;
    }
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
}
