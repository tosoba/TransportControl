import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:transport_control/api/vehicles_api_key.dart';
import 'package:transport_control/model/vehicles_response.dart';

part 'vehicles_api.g.dart';

@RestApi(baseUrl: "https://api.um.warszawa.pl/api/action")
abstract class VehiclesApi {
  factory VehiclesApi(Dio dio, {String baseUrl}) = _VehiclesApi;

  @GET("/busestrams_get")
  Future<VehiclesResponse> fetchAllVehicles(
    @Query("type") int type, {
    @Query("line") String line,
    @Query("resource_id")
        String resourceId = "f2e5503e-927d-4ad3-9500-4ab9e55deb59",
    @Query("apikey") String apiKey = vehiclesApiKey,
  });
}
