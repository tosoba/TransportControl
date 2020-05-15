import 'package:super_enum/super_enum.dart';
import 'package:transport_control/model/location_result.dart';

part "load_nearby_vehicles_result.g.dart";

@superEnum
enum _LoadNearbyVehiclesResult {
  @object
  Success,

  @object
  NoConnection,

  @Data(fields: [DataField<LocationResult>('locationResult')])
  FailedToGetUserLocation,
}
