import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:transport_control/model/place_suggestions_response.dart';

part 'places_api.g.dart';

@RestApi(baseUrl: "https://autosuggest.search.hereapi.com/v1")
@singleton
abstract class PlacesApi {
  factory PlacesApi(Dio dio, {String baseUrl}) = _PlacesApi;

  @GET("/autosuggest")
  Future<PlaceSuggestionsResponse> fetchSuggestions({
    @required @Query("q") String query,
    @Query('limit') int limit = 20,
    @Query('in') String area = 'circle:52.237049,21.017532;r=20000',
    @Query('lang') String language = 'PL',
    @Query("apikey") String key = _PlacesApiData.key,
  });

  @factoryMethod
  static PlacesApi create(Dio client) => PlacesApi(client);
}

class _PlacesApiData {
  static const key = '';
}
