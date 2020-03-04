import 'package:transport_control/model/result.dart';
import 'package:transport_control/model/vehicle.dart';
import 'package:transport_control/model/vehicles_response.dart';

extension FutureExt<T> on Future<T> {
  Future<Result<T>> get result => then((value) => Result.success(value),
      onError: (err) => Result.error(err));
}

extension VehiclesResponseFuture on Future<VehiclesResponse> {
  Future<Result<List<Vehicle>>> get vehiclesResult =>
      then((response) => response.vehicles).result;
}
