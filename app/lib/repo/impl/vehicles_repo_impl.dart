import 'package:injectable/injectable.dart';
import 'package:transport_control/api/vehicles_api.dart';
import 'package:transport_control/di/injection.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/repo/vehicles_repo.dart';

@RegisterAs(VehiclesRepo, env: Env.dev)
@singleton
class VehiclesRepoImpl extends VehiclesRepo {
  final VehiclesApi _api;

  VehiclesRepoImpl(this._api);

  @override
  Future<List<Vehicle>> loadVehicles(
      {int type, String line, double lat, double lon}) {
    return null;
  }
}
