import 'package:transport_control/model/vehicle.dart';

abstract class VehiclesRepo {
  Future<List<Vehicle>> loadVehicles({
    int type,
    String line,
    double lat,
    double lon,
  });
}
