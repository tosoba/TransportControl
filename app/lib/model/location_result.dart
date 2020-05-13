import 'package:location/location.dart';
import 'package:super_enum/super_enum.dart';

part "location_result.g.dart";

@superEnum
enum _LocationResult {
  @Data(fields: [DataField<LocationData>('data')])
  Success,

  @object
  ServiceUnavailable,

  @object
  PermissionDenied,

  @object
  PermissionDeniedForever,

  @Data(fields: [DataField<dynamic>('error')])
  Failure
}
