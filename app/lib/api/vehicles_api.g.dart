// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicles_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _VehiclesApi implements VehiclesApi {
  _VehiclesApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    this.baseUrl ??= 'https://api.um.warszawa.pl/api/action';
  }

  final Dio _dio;

  String baseUrl;

  @override
  fetchAllVehicles(type,
      {line,
      resourceId = "f2e5503e-927d-4ad3-9500-4ab9e55deb59",
      apiKey = vehiclesApiKey}) async {
    ArgumentError.checkNotNull(type, 'type');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      'type': type,
      'line': line,
      'resource_id': resourceId,
      'apikey': apiKey
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        '/busestrams_get',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = VehiclesResponse.fromJson(_result.data);
    return Future.value(value);
  }
}
