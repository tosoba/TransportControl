import 'package:json_annotation/json_annotation.dart';
import 'package:transport_control/model/geocoding_view.dart';

part 'geocoding_response.g.dart';

@JsonSerializable()
class GeocodingResponse {
  final List<GeocodingView> views;

  GeocodingResponse({this.views});

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    return _$GeocodingResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GeocodingResponseToJson(this);
}
