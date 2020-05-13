import 'package:location/location.dart';
import 'package:transport_control/model/location_result.dart';

extension LocationExt on Location {
  Future<LocationResult> tryGetLocation({
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    final permissionStatus = await hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return LocationResult.permissionDeniedForever();
    }

    if (permissionStatus == PermissionStatus.denied &&
        await requestPermission() != PermissionStatus.granted) {
      return LocationResult.permissionDenied();
    }

    if (!await serviceEnabled() && !await requestService()) {
      return LocationResult.serviceUnavailable();
    }

    return getLocation()
        .then((data) => LocationResult.success(data: data))
        .timeout(timeLimit)
        .catchError((error) => LocationResult.failure(error: error));
  }
}
