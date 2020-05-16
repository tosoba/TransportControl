// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _PlacesApi implements PlacesApi {
  _PlacesApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    this.baseUrl ??= 'https://autocomplete.geocoder.api.here.com/6.2';
  }

  final Dio _dio;

  String baseUrl;

  @override
  fetchSuggestions(
      {query,
      maxResults = 20,
      bounds = '52.237049,21.017532,20000',
      country = 'POL',
      language = 'PL',
      appId = PlacesApiData.appId,
      appCode = PlacesApiData.appCode}) async {
    ArgumentError.checkNotNull(query, 'query');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      'query': query,
      'maxresults': maxResults,
      'prox': bounds,
      'country': country,
      'language': language,
      'app_id': appId,
      'app_code': appCode
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/suggest.json',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = PlaceSuggestionsResponse.fromJson(_result.data);
    return Future.value(value);
  }
}
