import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:transport_control/model/vehicles_response.dart';

part 'vehicles_api.g.dart';

@RestApi(baseUrl: "https://api.um.warszawa.pl/api/action")
@singleton
abstract class VehiclesApi {
  factory VehiclesApi(Dio dio, {String baseUrl}) = _VehiclesApi;

  @GET("/busestrams_get")
  Future<VehiclesResponse> fetchVehicles({
    @Query("type") int type,
    @Query("line") String line,
    @Query("resource_id")
        String resourceId = "f2e5503e-927d-4ad3-9500-4ab9e55deb59",
    @Query("apikey") String apiKey = _VehiclesApiData.key,
  });

  @factoryMethod
  static VehiclesApi create(Dio client) => VehiclesApi(client);
}

class _VehiclesApiData {
  static const key = '<UM_WARSZAWA_API_KEY>';
}
