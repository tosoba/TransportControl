import 'package:transport_control/model/vehicle.dart';

extension VehicleExt on Vehicle {
  bool get isValid =>
      lat != null &&
      lon != null &&
      symbol != null &&
      brigade != null &&
      time != null;
}
