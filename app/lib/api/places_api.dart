import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:transport_control/model/place_suggestions_response.dart';

part 'places_api.g.dart';

@RestApi(baseUrl: "https://autocomplete.geocoder.api.here.com/6.2")
@singleton
abstract class PlacesApi {
  factory PlacesApi(Dio dio, {String baseUrl}) = _PlacesApi;

  @GET("/suggest.json")
  Future<PlaceSuggestionsResponse> fetchSuggestions({
    @required @Query("query") String query,
    @Query('maxresults') int maxResults = 20,
    @Query('prox') String bounds = '52.237049,21.017532,20000',
    @Query('country') String country = 'POL',
    @Query('language') String language = 'PL',
    @Query("app_id") String appId = PlacesApiData.appId,
    @Query("app_code") String appCode = PlacesApiData.appCode,
  });

  @factoryMethod
  static PlacesApi create(Dio client) => PlacesApi(client);
}

class PlacesApiData {
  static const appId = 'UojlDRBl2upvHhSYJEF1';
  static const appCode = '4QvUQmYhVJLYXd95Ng5iBg';
}
