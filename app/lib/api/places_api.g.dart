// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _PlacesApi implements PlacesApi {
  _PlacesApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    this.baseUrl ??= 'https://autosuggest.search.hereapi.com/v1';
  }

  final Dio _dio;

  String baseUrl;

  @override
  fetchSuggestions(
      {query,
      limit = 20,
      area = 'circle:52.237049,21.017532;r=20000',
      language = 'PL',
      key = _PlacesApiData.key}) async {
    ArgumentError.checkNotNull(query, 'query');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'q': query,
      r'limit': limit,
      r'in': area,
      r'lang': language,
      r'apikey': key
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/autosuggest',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = PlaceSuggestionsResponse.fromJson(_result.data);
    return value;
  }
}
